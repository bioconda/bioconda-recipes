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
      ``bioconda-utils/bioconda-utils_requirements.txt`` have been conda
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
import os.path
from shlex import quote
import shutil
import subprocess as sp
import tempfile
import pwd
import grp
from textwrap import dedent
import pkg_resources
import re
from distutils.version import LooseVersion

import conda
import conda_build

from . import utils

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
set -eo pipefail

# Add the host's mounted conda-bld dir so that we can use its contents as
# dependencies for building this recipe.
#
# Note that if the directory didn't exist on the host, then the staging area
# will exist in the container but will be empty.  Channels expect at least
# a linux-64 and noarch directory within that directory, so we make sure it
# exists before adding the channel.
mkdir -p {self.container_staging}/linux-64
mkdir -p {self.container_staging}/noarch
conda config --add channels file://{self.container_staging} 2> >(
    grep -vF "Warning: 'file://{self.container_staging}' already in 'channels' list, moving to the top" >&2
)

# The actual building...
# we explicitly point to the meta.yaml, in order to keep
# conda-build from building all subdirectories
conda build {self.conda_build_args} {self.container_recipe}/meta.yaml 2>&1

# copy all built packages to the staging area
cp `conda build {self.conda_build_args} {self.container_recipe}/meta.yaml --output` {self.container_staging}/{arch}
# Ensure permissions are correct on the host.
HOST_USER={self.user_info[uid]}
chown $HOST_USER:$HOST_USER {self.container_staging}/{arch}/*
"""  # noqa: E501,E122: line too long, continuation line missing indentation or outdented


# ----------------------------------------------------------------------------
# DOCKERFILE_TEMPLATE
# ----------------------------------------------------------------------------
#
# This template can be used for last-minute changes to the docker image, such
# as adding proxies.
#
# The default image is created automatically on DockerHub using the Dockerfile
# in the bioconda-utils repo.

DOCKERFILE_TEMPLATE = \
"""
FROM {docker_base_image}
{proxies}
RUN /opt/conda/bin/conda install -y conda={conda_ver} conda-build={conda_build_ver}
"""  # noqa: E122 continuation line missing indentation or outdented


class DockerCalledProcessError(sp.CalledProcessError):
    pass


class DockerBuildError(Exception):
    pass



def get_host_conda_bld():
    """
    Identifies the conda-bld directory on the host.

    Assumes that conda-build is installed.
    """
    # v0.16.2: this used to have a side effect, calling conda build purge
    # hopefully, it's not actually needed.
    build_conf = utils.load_conda_build_config()
    return build_conf.build_folder


class RecipeBuilder(object):
    def __init__(
        self,
        tag='tmp-bioconda-builder',
        container_recipe='/opt/recipe',
        container_staging="/opt/host-conda-bld",
        requirements=None,
        build_script_template=BUILD_SCRIPT_TEMPLATE,
        dockerfile_template=DOCKERFILE_TEMPLATE,
        use_host_conda_bld=False,
        pkg_dir=None,
        keep_image=False,
        build_image=False,
        image_build_dir=None,
        docker_base_image='bioconda/bioconda-utils-build-env:latest'
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
            the container can use previously-built packages as dependencies.
            Upon successful building container-built packages will be copied
            over. Mounted as read-write.

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

            Otherwise, use **pkg_dir** as a common host directory used across
            multiple runs of this RecipeBuilder object.

        pkg_dir : str or None
            Specify where packages should appear on the host.

            If **pkg_dir** is None, then a temporary directory will be
            created once for each `RecipeBuilder` instance and that directory
            will be used for each call to `RecipeBuilder.build_recipe()`. This allows
            subsequent recipes built by the container to see previous built
            recipes without polluting the host's conda-bld directory.

            If **pkg_dir** is a string, then it will be created if needed and
            this directory will be used store all built packages on the host
            instead of the temp dir.

            If the above argument **use_host_conda_bld** is `True`, then the value
            of **pkg_dir** will be ignored and the host's conda-bld directory
            will be used.

            In all cases, **pkg_dir** will be mounted to **container_staging** in
            the container.

        build_image : bool
            Build a local layer on top of the **docker_base_image** layer using
            **dockerfile_template**. This can be used to adjust the versions of
            conda and conda-build in the build container.

        keep_image : bool
            By default, the built docker image will be removed when done,
            freeing up storage space.  Set ``keep_image=True`` to disable this
            behavior.

        image_build_dir : str or None
            If not None, use an existing directory as a docker image context
            instead of a temporary one. For testing purposes only.

        docker_base_image : str or None
            Name of base image that can be used in **dockerfile_template**.
            Defaults to 'bioconda/bioconda-utils-build-env:latest'
        """
        self.requirements = requirements
        self.conda_build_args = ""
        self.build_script_template = build_script_template
        self.dockerfile_template = dockerfile_template
        self.keep_image = keep_image
        self.build_image = build_image
        self.image_build_dir = image_build_dir
        self.docker_base_image = docker_base_image
        self.docker_temp_image = tag

        # find and store user info
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

        # Copy the conda build config files to the staging directory that is
        # visible in the container
        for i, config_file in enumerate(utils.get_conda_build_config_files()):
            dst_file = self._get_config_path(self.pkg_dir, i, config_file)
            shutil.copyfile(config_file.path, dst_file)
        if self.build_image:
            self._build_image()

    def _get_config_path(self, staging_prefix, i, config_file):
        src_basename = os.path.basename(config_file.path)
        dst_basename = 'conda_build_config_{}_{}_{}'.format(i, config_file.arg, src_basename)
        return os.path.join(staging_prefix, dst_basename)

    def __del__(self):
        self.cleanup()

    def _find_proxy_settings(self):
        res = {}
        for var in ('http_proxy', 'https_proxy'):
            values = set([
                os.environ.get(var, None),
                os.environ.get(var.upper(), None)
            ]).difference([None])
            if len(values) == 1:
                res[var] = next(iter(values))
            elif len(values) > 1:
                raise ValueError(f"{var} and {var.upper()} have different values")
        return res

    def _build_image(self):
        """
        Builds a new image with requirements installed.
        """

        if self.image_build_dir is None:
            # Create a temporary build directory since we'll be copying the
            # requirements file over
            build_dir = tempfile.mkdtemp()
        else:
            build_dir = self.image_build_dir

        logger.info('DOCKER: Building image "%s" from %s', self.docker_temp_image, build_dir)
        with open(os.path.join(build_dir, 'requirements.txt'), 'w') as fout:
            if self.requirements:
                fout.write(open(self.requirements).read())
            else:
                fout.write(open(pkg_resources.resource_filename(
                    'bioconda_utils',
                    'bioconda_utils-requirements.txt')
                ).read())

        proxies = "\n".join("ENV {} {}".format(k, v)
                            for k, v in self._find_proxy_settings())

        with open(os.path.join(build_dir, "Dockerfile"), 'w') as fout:
            fout.write(self.dockerfile_template.format(
                docker_base_image=self.docker_base_image,
                proxies=proxies,
                conda_ver=conda.__version__,
                conda_build_ver=conda_build.__version__)
            )

        logger.debug('Dockerfile:\n' + open(fout.name).read())

        # Check if the installed version of docker supports the --network flag
        # (requires version >= 1.13.0)
        # Parse output of `docker --version` since the format of the
        #  `docker version` command (note the missing dashes) is not consistent
        # between different docker versions. The --version string is the same
        # for docker 1.6.2 and 1.12.6
        try:
            s = sp.check_output(["docker", "--version"]).decode()
        except FileNotFoundError:
            logger.error('DOCKER FAILED: Error checking docker version, is it installed?')
            raise
        except sp.CalledProcessError:
            logger.error('DOCKER FAILED: Error checking docker version.')
            raise
        p = re.compile(r"\d+\.\d+\.\d+")  # three groups of at least on digit separated by dots
        version_string = re.search(p, s).group(0)
        if LooseVersion(version_string) >= LooseVersion("1.13.0"):
            cmd = [
                    'docker', 'build',
                    # xref #5027
                    '--network', 'host',
                    '-t', self.docker_temp_image,
                    build_dir
            ]
        else:
            # Network flag was added in 1.13.0, do not add it for lower versions. xref #5387
            cmd = [
                    'docker', 'build',
                    '-t', self.docker_temp_image,
                    build_dir
            ]

        try:
            with utils.Progress():
                p = utils.run(cmd, mask=False)
        except sp.CalledProcessError as e:
            logger.error(
                'DOCKER FAILED: Error building docker container %s. ',
                self.docker_temp_image)
            raise e

        logger.info('DOCKER: Built docker image tag=%s', self.docker_temp_image)
        if self.image_build_dir is None:
            shutil.rmtree(build_dir)
        return p

    def build_recipe(self, recipe_dir, build_args, env, noarch=False):
        """
        Build a single recipe.

        Parameters
        ----------

        recipe_dir : str
            Path to recipe that contains meta.yaml

        build_args : str
            Additional arguments to ``conda build``. For example --channel,
            --skip-existing, etc

        env : dict
            Environmental variables

        noarch: bool
            Has to be set to true if this is a noarch build

        Note that the binds are set up automatically to match the expectations
        of the build script, and will use the currently-configured
        self.container_staging and self.container_recipe.
        """

        # Attach the build args to self so that it can be filled in by the
        # template.
        if not isinstance(build_args, str):
            raise ValueError('build_args must be str')
        build_args_list = [build_args]
        for i, config_file in enumerate(utils.get_conda_build_config_files()):
            dst_file = self._get_config_path(self.container_staging, i, config_file)
            build_args_list.extend([config_file.arg, quote(dst_file)])
        self.conda_build_args = ' '.join(build_args_list)

        # Write build script to tempfile
        build_dir = os.path.realpath(tempfile.mkdtemp())
        script = self.build_script_template.format(
            self=self, arch='noarch' if noarch else 'linux-64')
        with open(os.path.join(build_dir, 'build_script.bash'), 'w') as fout:
            fout.write(script)
        build_script = fout.name
        logger.debug('DOCKER: Container build script: \n%s', open(fout.name).read())

        # Build the args for env vars. Note can also write these to tempfile
        # and use --env-file arg, but using -e seems clearer in debug output.
        env_list = []
        for k, v in env.items():
            env_list.append('-e')
            env_list.append('{0}={1}'.format(k, v))

        env_list.append('-e')
        env_list.append('{0}={1}'.format('HOST_USER_ID', self.user_info['uid']))

        cmd = [
            'docker', 'run', '-t',
            '--net', 'host',
            '--rm',
            '-v', '{0}:/opt/build_script.bash'.format(build_script),
            '-v', '{0}:{1}'.format(self.pkg_dir, self.container_staging),
            '-v', '{0}:{1}'.format(recipe_dir, self.container_recipe),
        ]
        cmd += env_list
        if self.build_image:
            cmd += [self.docker_temp_image]
        else:
            cmd += [self.docker_base_image]
        cmd += ['/bin/bash', '/opt/build_script.bash']

        logger.debug('DOCKER: cmd: %s', cmd)
        with utils.Progress():
            p = utils.run(cmd, mask=False)
        return p

    def cleanup(self):
        if self.build_image and not self.keep_image:
            cmd = ['docker', 'rmi', self.docker_temp_image]
            utils.run(cmd, mask=False)


def purgeImage(mulled_upload_target, img):
    pkg_name_and_version, pkg_build_string = img.rsplit("--", 1)
    pkg_name, pkg_version = pkg_name_and_version.rsplit("=", 1)
    pkg_container_image = f"quay.io/{mulled_upload_target}/{pkg_name}:{pkg_version}--{pkg_build_string}"
    cmd = ['docker', 'rmi', pkg_container_image]
    o = utils.run(cmd, mask=False)
