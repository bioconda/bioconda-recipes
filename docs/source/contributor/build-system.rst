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
Docker, and CircleCI, while simultaneously supporting the same build system on
a local machine so contributors can test. We also have isolated bioconda-utils
from bioconda-recipes to better facilitate testing of the infrastructure, and
to (one day!) make it general enough that others can use the framework for
their own specific channels. So there are a lot of moving parts that have to be
coordinated, resulting in a complex system. That said, we do have some room to
simplify, and do so where we can.

Stages of a bioconda build
--------------------------
A GitHub pull request, or any pushed changes to a GitHub pull request, triggers
a new build on CircleCI. One build can contain mulitple recipes, limited only
by the time limit imposed by CircleCI (they have generously given us an
extended build time).  Each build on CircleCI starts with a fresh VM, so we
need to create the entire bioconda-build system environment from scratch for
each build.

When testing locally with ``circleci build``, we use the
``bioconda/bioconda-utils-build-env`` Docker container to avoid changing the
local system. This container is defined by `this Dockerfile
<https://github.com/bioconda/bioconda-utils/blob/master/Dockerfile>`_.


Otherwise, when running on CircleCI, a new Linux or MacOS VM is created for
each build.

The steps are orchestrated by the `circleci config file
<https://github.com/bioconda/bioconda-recipes/blob/master/.circleci/config.yml>`_.


Configure the environment
~~~~~~~~~~~~~~~~~~~~~~~~~

- Configure the CI environment:
    - ``bioconda-recipes: .circleci/config.yml`` is the primary configuration
      file for the steps that are run. See https://circleci.com/docs/2.0/ for
      the configuration documentation.
    - ``bioconda-common: common.sh`` defines the versions of Miniconda and
      bioconda-utils to use.
    - ``bioconda-recipes: .circleci/setup.sh`` installs Miniconda and
      bioconda-utils, sets the correct channel order

- Run linting on changed recipes
    - This is triggered by the ``bioconda-recipes: .circleci/config.yml`` "lint"
      job, which runs ``bioconda-utils: bioconda_utils/cli.py`` and
      ``bioconda_utils/linting.py``

- Build recipes
    - Triggered by the ``bioconda-recipes: .circleci/config.yaml`` "test-linux"
      job, which runs ``bioconda-utils build``. This performs the next steps.

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
    - A whitelist of env vars is exported. The whitelist is configured in
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
        - upload the built conda package to anaconda.org, with an optional label
        - upload the BusyBox container to quay.io

As soon as the package is uploaded to anaconda.org, it is available for
installing via ``conda``. As soon as the BusyBox container is uploaded to
quay.io, it is available for use via ``docker pull``.

The ``bulk`` branch
-------------------

Periodically, large-scale maintenance needs to be done on the channel. For
example, when a new version of Bioconductor comes out, we need to update all
``bioconductor-*`` packages and rebuild them. Or if we change the version of
a pinned package in ``scripts/env.yaml``, then all packages depending
on that package need to be rebuilt. While our build infrastructure will build
recipes in the correct toplogically sorted order, if there are too many recipes
then Travis-CI will timeout and the build will fail.

Our solution to avoiding builds failing due to timeouts is the special ``bulk``
branch. This branch is used by the bioconda core team for maintenance and
behaves much like the ``master`` branch in that packages, once successfully
built and tested, are immediately uploaded to anaconda.org. The major
difference is that ``bulk`` does not go through the pull-request-and-review
process in order for packages to be built and uploaded to the channel. As such,
only bioconda core members are able to push to the ``bulk`` branch.

The workflow is to first merge the latest master into ``bulk`` branch and
resolve any conflicts. Then push (often a large number of) changes to the
branch, without opening a PR. Unlike the ``master`` branch, which uses
the shortcut of only checking for recipes in the channel if they have been changed
according to ``git``, the ``bulk`` branch is configured to do the exhaustive
check against the channel (which can take some time). Any existing recipe that
does not exist in the channel will therefore be re-built. As packages build,
they are uploaded; as they fail, the testing moves on to the next package.  The
``bulk`` branch runs up until the Travis-CI timeout, at which time the entire
build fails. But since individual packages were uploaded as they are
successfully built, our work is saved and we can start the next build where we
left off. Failing tests are fixed in another round of commits, and these
changes are then pushed to ``bulk`` and the process repeats. Once ``bulk`` is
fully successful, a PR is opened to merge the changes into master.

Labels
------

If the ``BIOCONDA_LABEL`` environment variable is set, then all uploads will
have that label assigned to them, rather than ``main``. Consequently, they can
only be installed by adding ``-c bioconda/BIOCONDA_LABEL`` to the channels,
where ``BIOCONDA_LABEL`` is whatever that environment variable is set to. Note
that uploads of biocontainers to quay.io will still occur!
