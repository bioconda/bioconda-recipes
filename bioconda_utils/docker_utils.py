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
      where the requirements in `bioconda-utils/bioconda-utils_requirements.txt`
      have been conda installed.

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

import logging
logger = logging.getLogger(__name__)

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

# Add the host's mounted conda-bld dir so that we can use its contents as
# dependencies for building this recipe.
conda config --add channels file://{self.container_staging}

# The actual building....
conda build {self.conda_build_args} {self.container_recipe}

# Identify the output package
OUTPUT=$(conda build {self.container_recipe} --output)

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
# (the default is to use bioconda_utils-requierments.txt). THe
# RecipeBuilder._build_image
DOCKERFILE_TEMPLATE = \
"""
FROM {self.image}
COPY requirements.txt /tmp/requirements.txt
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


def get_host_conda_bld():
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
    # TODO: when we start running conda-build 2.0+, will need a `conda purge`
    # call to clean up temp recipes
    #sp.check_call(['conda', 'build', 'purge'])
    return res


class RecipeBuilder(object):
    def __init__(
        self,
        tag='tmp-bioconda-builder',
        container_recipe='/opt/recipe',
        container_staging="/opt/host-conda-bld",
        image='condaforge/linux-anvil',
        base_url='unix://var/run/docker.sock',
        requirements=None,
        build_script_template=BUILD_SCRIPT_TEMPLATE,
        dockerfile_template=DOCKERFILE_TEMPLATE,
        verbose=False,
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

        base_url : str
            Passed to docker.Client()

        requirements : None or str
            Path to a "requirements.txt" file which will be installed with
            conda in a newly-created container. If None, then use the default
            installed with bioconda_utils.

        build_script_template : str
            Template that will be filled in with .format(self=self) and that
            will be run in the container each time build_recipe() is called.

        dockerfile_template : str
            Template that will be filled in with .format(self=self) and that
            will be used to build a custom image.

        verbose : bool
        """
        self.image = image
        self.tag = tag
        self.verbose = verbose
        self.requirements = requirements
        self.conda_build_args = ""
        self.build_script_template = build_script_template
        self.dockerfile_template = dockerfile_template
        uid = os.getuid()
        usr = pwd.getpwuid(uid)
        self.user_info = dict(
            uid=uid,
            gid=usr.pw_gid,
            groupname=grp.getgrgid(usr.pw_gid).gr_name,
            username=usr.pw_name)
        self.container_recipe = container_recipe
        self.container_staging = container_staging

        # Don't import until here to allow module import if docker is not
        # installed.
        try:
            from docker import Client as DockerClient
        except ImportError:
            raise ImportError("docker-py module must be installed")
        self.docker = DockerClient(base_url=base_url)
        self.host_conda_bld = get_host_conda_bld()

        self._build_image()

    def _build_image(self):
        """
        Builds a new image with requirements installed.
        """

        # Create a temporary build directory since we'll be copying the
        # requirements file over
        build_dir = tempfile.mkdtemp()

        logger.debug('Building image "%s" from %s', self.tag, build_dir)
        with open(os.path.join(build_dir, 'requirements.txt'), 'w') as fout:
            if self.requirements:
                fout.write(open(self.requirements).read())
            else:
                fout.write(open(pkg_resources.resource_filename(
                    'bioconda_utils', 'bioconda_utils-requirements.txt')).read())

        with open(os.path.join(build_dir, "Dockerfile"), 'w') as fout:
            fout.write(self.dockerfile_template.format(self=self))

        logger.debug('Dockerfile:\n' + open(fout.name).read())

        response = list(self.docker.build(path=build_dir, rm=True, tag=self.tag, decode=True))
        for r in response:
            if 'error' in r:
                raise DockerBuildError(response)
        self._build = response
        logger.info('Built docker image tag=%s', self.tag)
        logger.debug(self._build)
        shutil.rmtree(build_dir)
        return self._build

    def build_recipe(self, recipe_dir, build_args, **kwargs):
        """
        Build a single recipe.

        Parameters
        ----------

        recipe_dir : str
            Path to recipe that contains meta.yaml

        build_args : str
            Additional arguments to `conda build`. For example --channel,
            --skip-existing, etc

        Additional kwargs are passed to docker.Client.create_container.
        (`environment` is a useful one).

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
        build_dir = tempfile.mkdtemp()
        with open(os.path.join(build_dir, 'build_script.bash'), 'w') as fout:
            fout.write(self.build_script_template.format(self=self))
        build_script = fout.name
        logger.debug('Container build script: \n%s', open(fout.name).read())

        logger.info('Building recipe with docker: %s', recipe_dir)

        binds = {
            build_script: {
                'bind': '/opt/build_script.bash',
                'mode': 'ro',
            },
            self.host_conda_bld: {
                'bind': self.container_staging,
                'mode': 'rw',
            },
            recipe_dir: {
                'bind': self.container_recipe,
                'mode': 'ro',
            },
        }
        logger.debug('binds: %s', binds)

        cmd = '/bin/bash /opt/build_script.bash'
        logger.debug('cmd: %s', cmd)
        logger.debug('kwargs: %s', kwargs)
        container = self.docker.create_container(
            image=self.tag,
            command=cmd,
            host_config=self.docker.create_host_config(
                binds=binds, network_mode='host'
            ),
            **kwargs)

        cid = container['Id']
        logger.debug('Container ID: %s', cid)

        self.docker.start(container=cid)
        status = self.docker.wait(container=cid)
        stdout = self.docker.logs(container=cid, stdout=True, stderr=False).decode()
        stderr = self.docker.logs(container=cid, stderr=True, stdout=False).decode()

        logger.debug('cmd:\n%s', cmd)
        logger.debug('stdout:\n%s', stdout)
        logger.debug('stderr:\n%s', stderr)

        if status != 0:
            raise DockerCalledProcessError(
                status, cmd, output=stdout, stderr=stderr)

        return dict(status=status, stdout=stdout, stderr=stderr, cmd=cmd)
