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


class DockerCalledProcessError(sp.CalledProcessError):
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

        verbose : bool
        """
        self.image = image
        self.tag = tag
        self.verbose = verbose
        self.requirements = requirements
        uid = os.getuid()
        usr = pwd.getpwuid(uid)
        self.user_info = dict(
            uid=uid,
            gid=usr.pw_gid,
            groupname=grp.getgrgid(usr.pw_gid).gr_name,
            username=usr.pw_name)
        self.container_recipe = container_recipe
        self.container_staging = container_staging

        # Don't import until here to allow module import if docker not
        # installed.
        try:
            from docker import Client as DockerClient
        except ImportError:
            raise ImportError("docker-py module must be installed")
        self.docker = DockerClient(base_url=base_url)
        self.host_conda_bld = get_host_conda_bld()
        self._build_container()

    def _build_container(self):
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
            fout.write(dedent(
                """\
                FROM {self.image}
                COPY requirements.txt /tmp/requirements.txt
                RUN /opt/conda/bin/conda install --file /tmp/requirements.txt
                """.format(**locals())))

        logger.debug('Dockerfile:\n' + open(fout.name).read())

        # TODO: need a better way of detecting build failure
        response =self.docker.build(path=build_dir, rm=True, tag=self.tag)
        response = ''.join(i.decode() for i in response)
        if 'errorDetail' in response:
            raise ValueError(''.join(response))

        self._build = response
        logger.info('Built docker image tag=%s', self.tag)
        logger.debug(self._build)
        shutil.rmtree(build_dir)
        return self._build

    def _write_build_script(self):
        """
        Writes a script to do the recipe building and copying over to mounted
        host dir.

        Filled in using currently-configured self.container_recipe and
        self.container_staging.

        Expects `HOST_USER` and `CONDA_BUILD_ARGS` to be passed in as
        environmental variables.
        """
        build_dir = tempfile.mkdtemp()
        with open(os.path.join(build_dir, 'build_script.bash'), 'w') as fout:
            fout.write(dedent(
                """
                #!/bin/bash
                set -e
                conda config --add channels file://{self.container_staging}
                conda index {self.container_staging}/linux-64
                echo "Using {self.container_staging} for recipes"
                OUTPUT=$(conda build {self.container_recipe} --output)
                conda build $CONDA_BUILD_ARGS {self.container_recipe}

                # If CONDA_BUILD_ARGS contains args that make conda-build run
                # and exit 0 without creating a recipe (e.g., -h or
                # --skip-existing), then there's nothing to copy over.
                if [[ -e $OUTPUT ]]; then
                    cp $OUTPUT {self.container_staging}/linux-64
                    chown $HOST_USER:$HOST_USER {self.container_staging}/linux-64/$(basename $OUTPUT)
                fi
                """.format(self=self)))
        return fout.name

    def build_recipe(self, recipe_dir, build_args, **kwargs):
        """
        Build a single recipe.

        Parameters
        ----------

        recipe_dir : str
            Path to recipe that contains meta.yaml

        build_args : str
            Additional arguments to `conda build`. For example channels,
            --skip-existing, etc

        Additional kwargs are passed to docker.Client.create_container.
        `environment` is a useful one; note that HOST_USER and CONDA_BUILD_ARGS
        are added by this method. Also note that the binds are set up
        automatically to match the expectations of the build script, and use
        the currently-configured self.container_staging and
        self.container_recipe.
        """

        logger.info('Building recipe with docker: %s', recipe_dir)
        if not isinstance(build_args, str):
            raise ValueError('build_args must be str')

        # build_script.bash uses these
        _env = {
            'HOST_USER': self.user_info['uid'],
            'CONDA_BUILD_ARGS': build_args,
        }
        _env.update(kwargs.pop('environment', {}))

        build_script = self._write_build_script()
        cmd = '/bin/bash /opt/build_script.bash'
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
        logger.debug('environment: %s', _env)
        logger.debug('cmd: %s', cmd)
        logger.debug('binds: %s', binds)

        container = self.docker.create_container(
            image=self.tag,
            command=cmd,
            environment=_env,
            host_config=self.docker.create_host_config(binds=binds, network_mode='host'),
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
