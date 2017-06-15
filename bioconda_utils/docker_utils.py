#!/usr/bin/env python

"""
To ensure conda packages are built in the most compatible manner, we can use
a docker container. This module supports using a docker container to build
conda packages in the local channel which can later be uploaded to anaconda.

Note that  we cannot simply bind the host's conda-bld directory to the
container's conda-bld directory because during building/testing, symlinks are
made to the conda-pkgs dir which is not necessarily bound. Nor should it be, if
we want to retain isolation from the host when building.

To solve this, we mount the host's conda-bld dir to a temporary directory in
the container. Once the container successfully builds a package, the
corresponding package is copied over to the temporary directory (the host's
conda-bld directory) so that the built package appears on the host.

In the end the workflow is:

    - build a custom docker container (assumed to already have conda installed)
      where the requirements in
      `bioconda-utils/bioconda-utils_requirements.txt` have been conda
      installed.

    - mount the host's conda-bld to a read/write temporary dir in the container
      (configured in the RecipeBuilder)

    - in the container, add this directory as a local channel so that all
      previously-built packages can be used as dependencies.

    - mount the host's recipe dir to a read-only dir in the container
      (configured in the RecipeBuilder)

    - build, mount, and run a custom script that conda-builds the mounted
      recipe and if successful copies the built package to the mounted host's
      conda-bld directory.

Other notes:

- Most communication with the host (conda-bld options; host's UID) is via
  environmental variables passed to the container.

- The build script is custom generated each run, providing lots of flexibility.
  Most magic happens here.
"""

import os
import shutil
import subprocess as sp
import tempfile
import pwd
import grp
import argparse
from io import BytesIO
from textwrap import dedent
import pkg_resources

from . import utils

import logging
logger = logging.getLogger(__name__)


# If conda_build_version is not provided, this is what is used by default.
DEFAULT_CONDA_BUILD_VERSION = '2.1.15'
DEFAULT_CONDA_VERSION = '4.3.21'


# ----------------------------------------------------------------------------
# BUILD_SCRIPT_TEMPLATE
# ----------------------------------------------------------------------------
#
# The following script is the default that will be regenerated on each call to
# RecipeBuilder.build_recipe() and mounted at container run time when building
# a recipe. It can be overridden by providing a different template when calling
# RecipeBuilder.build_recipe().
#
# It will be filled in using BUILD_SCRIPT_TEMPLATE.format(self=self), so you
# can add additional attributes to the RecipeBuilder instance and have them
# filled in here.
#
BUILD_SCRIPT_TEMPLATE = \
"""
#!/bin/bash
set -e

conda install conda-build={self.conda_build_version} conda={self.conda_version}  > /dev/null 2>&1

# Add the host's mounted conda-bld dir so that we can use its contents as
# dependencies for building this recipe.
#
# Note that if the directory didn't exist on the host, then the staging area
# will exist in the container but will be empty.  Channels expect at least
# a linux-64 directory within that directory, so we make sure it exists before
# adding the channel.
mkdir -p {self.container_staging}/linux-64
conda config --add channels file://{self.container_staging}  > /dev/null 2>&1

# The actual building....
conda build {self.conda_build_args} {self.container_recipe} 2>&1

# Identify the output package
OUTPUT=$(conda build {self.container_recipe} --output 2> /dev/null)

# Some args to conda-build make it run and exit 0 without creating a package
# (e.g., -h or --skip-existing), so check to see if there's anything to copy
# over first.
if [[ -e $OUTPUT ]]; then

    # Copy over the recipe from where the container built it to the mounted
    # conda-bld dir from the host. Since docker containers are Linux, we assume
    # here that we want the linux-64 arch.
    cp $OUTPUT {self.container_staging}/linux-64

    # Ensure permissions are correct on the host.
    HOST_USER={self.user_info[uid]}
    chown $HOST_USER:$HOST_USER {self.container_staging}/linux-64/$(basename $OUTPUT)

    conda index {self.container_staging}/linux-64 > /dev/null 2>&1
fi
"""


# ----------------------------------------------------------------------------
# DOCKERFILE_TEMPLATE
# ----------------------------------------------------------------------------
#
# This Docker file is used by RecipeBuilder and sent to docker build if no
# other Dockerfile is provided to RecipeBuilder. It will be filled in using
# DOCKERFILE.format(self=self).
#
# It assumes that there will be a requirements.txt in the build directory
# (the default is to use bioconda_utils-requirements.txt).
DOCKERFILE_TEMPLATE = \
"""
FROM {self.image}
COPY requirements.txt /tmp/requirements.txt
RUN /opt/conda/bin/conda config --add channels defaults
RUN /opt/conda/bin/conda config --add channels conda-forge
RUN /opt/conda/bin/conda config --add channels bioconda
RUN /opt/conda/bin/conda install --file /tmp/requirements.txt
"""


class DockerCalledProcessError(sp.CalledProcessError):
    pass


class DockerBuildError(Exception):
    pass


def dummy_recipe():
    """
    Builds a throwaway recipe in a temp dir.

    The best way to figure out where a recipe will be built seems to be by
    running `conda build --output $RECIPE`, but this means a recipe has to
    exist. This creates a minimal meta.yaml file in a temp dir that can be used
    as an example recipe.

    Caller is expected to delete when done.
    """
    tmpdir = tempfile.mkdtemp()
    meta = os.path.join(tmpdir, 'meta.yaml')
    with open(meta, 'w') as fout:
        fout.write(dedent(
            """
            package:
                name: deleteme
            """))
    return tmpdir


def get_host_conda_bld(purge=True):
    """
    Identifies the conda-bld directory on the host.

    Assumes that conda-build is installed.
    """
    recipe = dummy_recipe()
    res = os.path.dirname(
        os.path.dirname(
            sp.check_output(
                ['conda', 'build', recipe, '--output'],
                universal_newlines=True
            ).splitlines()[0]
        )
    )
    if purge:
        sp.check_call(['conda', 'build', 'purge'])
    return res


class RecipeBuilder(object):
    def __init__(
        self,
        tag='tmp-bioconda-builder',
        container_recipe='/opt/recipe',
        container_staging="/opt/host-conda-bld",
        image='condaforge/linux-anvil',
        requirements=None,
        build_script_template=BUILD_SCRIPT_TEMPLATE,
        dockerfile_template=DOCKERFILE_TEMPLATE,
        use_host_conda_bld=False,
        conda_build_version=DEFAULT_CONDA_BUILD_VERSION,
        conda_version=DEFAULT_CONDA_VERSION,
        pkg_dir=None,
    ):
        """
        Class to handle building a custom docker container that can be used for
        building conda recipes.

        Parameters
        ----------
        tag : str
            Tag to be used for the custom-build docker container. Mostly for
            debugging purposes when you need to inspect the container.

        container_recipe : str
            Directory to which the host's recipe will be exported. Will be
            read-only.

        container_staging : str
            Directory to which the host's conda-bld dir will be mounted so that
            the container can use previously-built packages as depdendencies.
            Upon successful building container-built packages will be copied
            over. Mounted as read-write.

        image : str
            Base image from which the new custom image will be built (used on
            the `FROM:` line of the Dockerfile)

        requirements : None or str
            Path to a "requirements.txt" file which will be installed with
            conda in a newly-created container. If None, then use the default
            installed with bioconda_utils.

        build_script_template : str
            Template that will be filled in with .format(self=self) and that
            will be run in the container each time build_recipe() is called. If
            not specified, uses docker_utils.BUILD_SCRIPT_TEMPLATE.

        dockerfile_template : str
            Template that will be filled in with .format(self=self) and that
            will be used to build a custom image. Uses
            docker_utils.DOCKERFILE_TEMPLATE by default.

        use_host_conda_bld : bool
            If True, then use the host's conda-bld directory. This will export
            the host's existing conda-bld directory to the docker container,
            and any recipes successfully built by the container will be added
            here.

            Otherwise, use `pkg_dir` as a common host directory used across
            multiple runs of this RecipeBuilder object.

        pkg_dir : str or None
            Specify where packages should appear on the host.

            If `pkg_dir` is None, then a temporary directory will be
            created once for each RecipeBuilder instance and that directory
            will be used for each call to `RecipeBuilder.build()`. This allows
            subsequent recipes built by the container to see previous built
            recipes without polluting the host's conda-bld directory.

            If `pkg_dir` is a string, then it will be created if needed and
            this directory will be used store all built packages on the host
            instead of the temp dir.

            If the above argument `use_host_conda_bld` is True, then the value
            of `pkg_dir` will be ignored and the host's conda-bld directory
            will be used.

            In all cases, `pkg_dir` will be mounted to `container_staging` in
            the container.
        """
        self.image = image
        self.tag = tag
        self.requirements = requirements
        self.conda_build_args = ""
        self.build_script_template = build_script_template
        self.dockerfile_template = dockerfile_template
        self.conda_build_version = conda_build_version
        self.conda_version = conda_version

        uid = os.getuid()
        usr = pwd.getpwuid(uid)
        self.user_info = dict(
            uid=uid,
            gid=usr.pw_gid,
            groupname=grp.getgrgid(usr.pw_gid).gr_name,
            username=usr.pw_name)
        self.container_recipe = container_recipe
        self.container_staging = container_staging

        self.host_conda_bld = get_host_conda_bld()

        if use_host_conda_bld:
            self.pkg_dir = self.host_conda_bld
        else:
            if pkg_dir is None:
                self.pkg_dir = tempfile.mkdtemp()
            else:
                if not os.path.exists(pkg_dir):
                    os.makedirs(pkg_dir)
                self.pkg_dir = pkg_dir

        self._pull_image()
        self._build_image()

    def __del__(self):
        self.cleanup()

    def _pull_image(self):
        """
        Separate out the pull step to provide additional logging info
        """
        logger.info('DOCKER: Pulling docker image %s', self.image)
        p = utils.run(['docker', 'pull', self.image])
        logger.debug('DOCKER: stdout+stderr:\n%s', p.stdout)
        logger.info('DOCKER: Done pulling image')

    def _build_image(self):
        """
        Builds a new image with requirements installed.
        """

        # Create a temporary build directory since we'll be copying the
        # requirements file over
        build_dir = tempfile.mkdtemp()

        logger.info('DOCKER: Building image "%s" from %s', self.tag, build_dir)
        with open(os.path.join(build_dir, 'requirements.txt'), 'w') as fout:
            if self.requirements:
                fout.write(open(self.requirements).read())
            else:
                fout.write(open(pkg_resources.resource_filename(
                    'bioconda_utils',
                    'bioconda_utils-requirements.txt')
                ).read())

        with open(os.path.join(build_dir, "Dockerfile"), 'w') as fout:
            fout.write(self.dockerfile_template.format(self=self))

        logger.debug('Dockerfile:\n' + open(fout.name).read())

        cmd = [
            'docker', 'build',
            '-t', self.tag,
            build_dir
        ]
        try:
            with utils.Progress():
                p = utils.run(cmd)
        except sp.CalledProcessError as e:
            logger.error(
                'DOCKER FAILED: Error building docker container %s. ',
                self.tag)
            raise e

        logger.info('DOCKER: Built docker image tag=%s', self.tag)
        shutil.rmtree(build_dir)
        return p

    def build_recipe(self, recipe_dir, build_args, env):
        """
        Build a single recipe.

        Parameters
        ----------

        recipe_dir : str
            Path to recipe that contains meta.yaml

        build_args : str
            Additional arguments to `conda build`. For example --channel,
            --skip-existing, etc

        env : dict
            Environmental variables

        Note that the binds are set up automatically to match the expectations
        of the build script, and will use the currently-configured
        self.container_staging and self.container_recipe.
        """

        # Attach the build args to self so that it can be filled in by the
        # template.
        if not isinstance(build_args, str):
            raise ValueError('build_args must be str')
        self.conda_build_args = build_args

        # Write build script to tempfile
        build_dir = os.path.realpath(tempfile.mkdtemp())
        with open(os.path.join(build_dir, 'build_script.bash'), 'w') as fout:
            fout.write(self.build_script_template.format(self=self))
        build_script = fout.name
        logger.debug('DOCKER: Container build script: \n%s', open(fout.name).read())


        # Build the args for env vars. Note can also write these to tempfile
        # and use --env-file arg, but using -e seems clearer in debug output.
        env_list = []
        for k, v in env.items():
            env_list.append('-e')
            env_list.append('{0}={1}'.format(k, v))

        cmd = [
            'docker', 'run',
            '--net', 'host',
            '--rm',
            '-v', '{0}:/opt/build_script.bash'.format(build_script),
            '-v', '{0}:{1}'.format(self.pkg_dir, self.container_staging),
            '-v', '{0}:{1}'.format(recipe_dir, self.container_recipe),
        ] + env_list + [
            self.tag,
            '/bin/bash', '/opt/build_script.bash',
        ]

        logger.debug('DOCKER: cmd: %s', cmd)
        with utils.Progress():
            p = utils.run(cmd)
        return p

    def cleanup(self):
        cmd = ['docker', 'rmi', self.tag]
        utils.run(cmd)
