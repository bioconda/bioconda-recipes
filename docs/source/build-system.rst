Build system
============

The build system for Bioconda takes recipes and converts them into conda
packages that are uploaded to anaconda.org as well as Docker containers that
are uploaded to quay.io. All of this happens in a transparent way, with all
build logs available for inspection. The code for the build system can be found
in `bioconda-utils <https://github.com/bioconda/bioconda-utils>`_, but parts
are also with the ``bioconda-recipes`` repo. This document serves as
a high-level overview; the code remains the authoritative source on exactly
what happens during a build.


Why so complicated? We have to work within the constraints of conda-build,
Docker, and Travis-CI, while simultaneously supporting the same build system on
a local machine so contributors can test. We also have isolated bioconda-utils
from bioconda-recipes to better facilitate testing of the infrastructure, and
to (one day!) make it general enough that others can use the framework for
their own specific channels. So there are a lot of moving parts that have to be
coordinated, resulting in a complex system. That said, we do have some room to
simplify, and do so where we can.


A GitHub pull request, or any pushed changes to a GitHub pull request, triggers
a new build on Travis-CI. Each build on Travis-CI starts with a fresh VM, so we
need to create the entire bioconda-build system environment from scratch for
each build.

One build can contain mulitple recipes, limited only by the time limit imposed
by Travis-CI (they have generously given us an extended build time). Each build
has the following stages; the relevant files in the relevant repos are
indicated.

- Install necessary packages on the VM
    - ``bioconda-recipes: .travis.yml``: configures setup script and env vars
    - ``bioconda-recipes: scripts/travis-setup.sh``: the actual setup script;
      ends with adding local channel so that subsequent packages can use
      previously built packages as dependencies
    - ``bioconda-recipes: simulate-travis.py``: called by the setup script;
      this installs miniconda and configures bioconda and conda-forge channels

- Start a build
    - ``bioconda-recipes: scripts/travis-run.sh``: handles different ways
      a build could be triggered on travis-ci and handles them appropriately
    - ``bioconda-recipes: .travis.yml``: env vars defined here

- Run linting on those changed recipes
  - ``bioconda-utils: bioconda_utils/cli.py``, ``bioconda_utils/linting.py``

- Filter recipes to only focus on recipes that satisfy the following criteria:
    - changed recently (we use a ``git diff`` command to identify these
      recipes; see ``bioconda-utils: bioconda_utils/build.py``
    - not on any blacklists listed in ``config.yaml``
    - package with that version number and build number does not exist in
      bioconda channel (we check the channel for each of the changed recipes)

- Download the configured Docker container (currently based on CentOS 6)
    - default configured in ``bioconda-utils: docker_utils.py``

- Build a new, temporary Docker container
    - Dockerfile configured in ``bioconda-utils: docker_utils.py``; we hope to
      move to simply pulling from DockerHub now that our build dependencies are
      not changing as often)

- Topologically sort changed recipes, and build them one-by-one in the Docker
  container. This runs ``conda-build`` on the recipe while also specifying the
  correct environment variables.
    - The conda-build directory is exported to the docker container to a temp
      file and added as a channel. This way, packages built by one container
      will be visible to containers building subsequent packages in the same
      Travis-CI build.
    - ``bioconda-utils: docker_utils.py`` specifies the build script that is
      run in the container.
    - At the end of the build, the build script copies the package to the
      exported conda-bld directory
    - ``bioconda-recipes: scripts/env_matrix.yml``: each unique combination of
      env vars defined here will create an independent build
    - A whitelist of env vars (including those defined in the
      ``env_matrix.yml``) is exported. The whitelist is configured in
      ``bioconda-utils: utils.py``.

- Upon successfully building and testing via ``conda-build``, the built package
  is added to a minimal BusyBox container using ``mulled-build`` (maintained in
  `galaxy-lib <https://github.com/galaxyproject/galaxy-lib>`_). This acts as
  a more stringent test than ``conda-build`` alone. The BusyBox container
  purposefully is missing many system libraries (like libgcc) that may be
  present in the CentOS 6 container. Note that it is common for a package to
  build in the CentOS 6 container but fail in the BusyBox container. When this
  happens, it is often because a dependency needs to be added to the recipe.

- Upon successfully testing the package in the BusyBox container, we have a branch point:

    - if we are on a pull request:
        - report the successful test back to the GitHub PR, at which time it
          can be merged into the master branch
    - if we are on the master branch:
        - upload the built conda package to anaconda.org
        - upload the BusyBox container to quay.io

As soon as the package is uploaded to anaconda.org, it is available for
installing via ``conda``. As soon as the BusyBox container is uploaded to
quay.io, it is available for use via ``docker pull``.
