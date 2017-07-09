Contributing a recipe
---------------------

The following steps are done for each recipe or batch of recipes you'd like to
contribute.

Update repo and requirements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Before starting, it's best to update your fork with any changes made
   recently to the upstream bioconda repo. Assuming you've set up your fork as
   :ref:`above <github-setup>`:

.. code-block:: bash

    git checkout master
    git pull upstream master

2. Set up the channel order and install the versions of dependencies
   currently used in the master branch. The channel order should generally stay
   the same and the dependencies are not likely to change much, but this
   ensures that the local environment most closely resembles the build
   environment on travis-ci:

.. code-block:: bash

    ./simulate-travis.py --set-channel-order
    ./simulate-travis.py --install-requirements


Write a recipe
~~~~~~~~~~~~~~


Check out a new branch in your fork (here the branch is arbitrarily named "my-recipe"):

.. code-block:: bash

    git checkout -b my-recipe

and write one or more recipes. The `conda-build docs
<http://conda.pydata.org/docs/building/recipe.html>`_ are the authoritative
source for information on building a recipe.

Please familiarize yourself with the :ref:`guidelines` for details on
bioconda-specific policies.


.. _test-locally:

Test locally
~~~~~~~~~~~~
To make sure your recipe works, there are several options. The quickest, but
not necessarily most complete, is to run conda-build directly::

    conda build <recipe-dir>

To test the recipe in a way more representative of the travis-ci environment,
use the `simulate-travis.py` script in the top-level directory of the repo.
Currently, it is mandatory to build any recipe *before* using
`simulate-travis.py` for the first time. `simulate-travis.py` reads the config
files in the repo and sets things up as closely as possible to how the builds
will be run on travis-ci. It should be run from the top-level dir of the repo.
Any arguments are passed on to the `bioconda-utils build` command, so check
`bioconda-utils build -h` for help and more options.

Some example commands:

This tests everything, using the installed conda-build. It will check all
recipes to see what needs to be built and so it is the most comprehensive::

    ./simulate-travis.py

Same thing but using `--docker`. If you're on OSX and have docker installed,
you can use this to test the recipe under Linux::

    ./simulate-travis.py --docker

Use the `--quick` option which will just check recipes that have changed since
the last commit to master branch or that have been newly removed from any
configured blacklists. This can help speed up the recipe filter stage which can
take 5 mins to thoroughly check 1500+ recipes. Note that this will not find
cases where a pinned version (e.g., `{ CONDA_BOOST }`) has been changed::

    ./simulate-travis.py --docker --quick

To specify exactly which packages you want to try building, use the
`--packages` argument. Note that the arguments to `--packages` can be globs and
are of package *names* rather than *paths* to recipe directories. For example,
to consider all R and Bioconductor packages::

    ./simulate-travis.py --docker --package r-* bioconductor-*


.. seealso::

    See :ref:`reading-logs` for tips on finding the information you need from
    log files.

Push changes, wait for tests to pass, submit pull request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before pushing your changes to your fork on github, it's best to merge any
changes that have happened recently on the upstream master branch. See
`sycncing a fork <https://help.github.com/articles/syncing-a-fork/>`_ for
details, or:

.. code-block:: bash

    git fetch upstream

    # syncs the fork's master branch with upstream
    git checkout master
    git merge upstream/master

    # merges those changes into the recipe's branch
    git checkout my-recipe
    git merge master


Push your changes to your fork on github::

    git push origin my-recipe


and watch the Travis-CI logs by going to travis-ci.org and finding your fork of
bioconda-recipes. Keep making changes on your fork and pushing them until the
travis-ci builds pass.

Open a `pull request <https://help.github.com/articles/about-pull-requests/>`_
on the bioconda-recipes repo. If it's your first recipe or the recipe is doing
something non-standard, please ask `@bioconda/core` for a review.

Use your new recipe
~~~~~~~~~~~~~~~~~~~

When the PR is merged with the master branch, travis-ci will again do the
builds but at the end will upload the packages to anaconda.org. Once the merge
build completes, your new package is installable by anyone using::

    conda install my-package-name -c bioconda

You should recommend to your users that they set up the same channel order as
used by bioconda to ensure that all dependencies are correctly met, by doing
the following::

    conda config --add channels defaults
    conda config --add channels conda-forge
    conda config --add channels bioconda
