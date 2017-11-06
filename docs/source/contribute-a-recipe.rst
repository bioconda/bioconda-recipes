Contributing a recipe
---------------------

The following steps are done for each recipe or batch of recipes you'd like to
contribute.

1. Update repo
~~~~~~~~~~~~~~

If you're using a fork (set up as :ref:`above <github-setup>`):

.. code-block:: bash

    git checkout master
    git pull upstream master
    git push origin master

If you're using a clone:

.. code-block:: bash

    git checkout master
    git pull origin master

2. Build an isolated conda installation with dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the top level of the bioconda-recipes repo, run:

.. code-block:: bash

    ./simulate-travis.py --bootstrap /tmp/miniconda --overwrite

This will:

- create a conda installation in ``/tmp/miniconda`` that is separate from any
  Python or conda you might already have on your system. No root privileges are
  needed.
- set up the proper channel order
- install ``bioconda-utils`` and its dependencies into that installation
- write a config file at ``~/.config/bioconda/config.yml`` to persistently
  store the location of this new installation so that subsequent calls to
  ``simulate-travis.py`` will use it with no further configuration.


.. note::

    If you plan on running `bioconda-utils` outside the context of
    `simulate-travis.py` -- for example to build recipe skeletons, inspect the
    DAG of recipes, or other maintenance and development work -- you need to
    call it using its full path. If you used ``/tmp/miniconda`` as the
    bootstrap path in the command above, then use
    ``/tmp/miniconda/bin/bioconda-utils``.

    This is by design: we want to keep all bioconda-related tools, which may
    have specific dependencies that must exist in the root environment,
    isolated from any environments you may have on your system.

.. note::

    The bootstrap operation runs relatively quickly, so you might consider
    running it every time you build and test a new recipe to ensure tests on
    travis-ci go as smoothly as possible.

    If you are running into particularly difficult-to-troubleshoot issues, try
    removing the installation directory completely and then re-installing using
    the ``--bootstrap`` argument.

3. Write a recipe
~~~~~~~~~~~~~~~~~

Check out a new branch (here the branch is arbitrarily named "my-recipe"):

.. code-block:: bash

    git checkout -b my-recipe

and write one or more recipes. The `conda-build docs
<http://conda.pydata.org/docs/building/recipe.html>`_ are the authoritative
source for information on building a recipe.

Please familiarize yourself with the :ref:`guidelines` for details on
bioconda-specific policies.


.. _test-locally:

4. Test locally
~~~~~~~~~~~~~~~

To test the recipe in a way more representative of the travis-ci environment,
use the ``simulate-travis.py`` script in the top-level directory of the repo.

``simulate-travis.py`` reads the config files in the repo and sets things up as
closely as possible to how the builds will be run on travis-ci. It should be
run from the top-level dir of the repo.  See ``simulate-travis.py -h`` for
details; below are some example uses.

.. note::

    Previously, it was mandatory to build any recipe *before* using
    `simulate-travis.py` for the first time. Recent changes should have fixed
    this, but if you see errors related to a directory not being found in the
    docker container, try building any recipe locally with conda-build. If you used
    using the ``--bootstrap`` method described above, make sure you call
    conda-build from that path explicitly, e.g.::

        /tmp/miniconda/bin/conda-build recipes/snakemake


Example commands
++++++++++++++++
The following commands assume you have run ``./simulate-travis.py --bootstrap
/tmp/miniconda``.

Recommended usage: build and test recipes with commits that have changed since
the master branch in a Docker container, and then run independent tests with
``mulled-build``.  This most closely replicates the work performed on
travis-ci::

    ./simulate-travis.py

Same as above, but also test recipes that have changes not yet committed to git::

    ./simulate-travis.py --git-range HEAD

Same as above, but disable the use of Docker when building packages and disable
the stringent ``mulled-build`` tests. Therefore even if this command passes it
still might fail on travis-ci, but it is useful for cases where Docker is
unavailable::

    ./simulate-travis.py --git-range HEAD --disable-docker

By default, packages whose version and build number match an existing package
in the bioconda channel will not be built.

To specify exactly which packages you want to try building, use the
`--packages` argument. Note that the arguments to `--packages` can be globs and
are of package *names* rather than *paths* to recipe directories. For example,
to consider all R and Bioconductor packages::

    ./simulate-travis.py --packages r-* bioconductor-*

However if those packages already exist in the bioconda channel, they will not
be built. To force a package::

    ./simulate-travis.py --packages snakemake --force

To force **all** packages (warning, this will *rebuild all packages* and will
consume lots of resources::

    # You probably don't want to run this.
    # ./simulate-travis.py --force

.. seealso::

    See :ref:`reading-logs` for tips on finding the information you need from
    log files.

5. Push changes, wait for tests to pass, submit pull request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Push your changes to your fork or to the main repo (if using a clone) to GitHub::

    git push origin my-recipe

If using a fork, watch the Travis-CI logs by going to travis-ci.org and finding
your fork of bioconda-recipes. Keep making changes on your fork and pushing
them until the travis-ci builds pass. When they pass, create a `pull request
<https://help.github.com/articles/about-pull-requests/>`_ on the main bioconda
repo for your changes.

If using a clone, you will have to open a pull request to get the tests to run.
The travis-ci tests intentionally short-circuit when not on a pull request to
save on resources.

Make and push changes as needed to get the tests to pass. If it's your first
recipe or the recipe is doing something non-standard, please
ask `@bioconda/core` for a review. If you are a member of the bioconda team,
feel free to merge your recipe once the tests pass.

At this point, Travis-CI will test your contribution in full.

6. Use your new recipe
~~~~~~~~~~~~~~~~~~~~~~
When the PR is merged with the master branch, travis-ci will again do the
builds but at the end will upload the packages to anaconda.org. Once this
completes, and as long as the channels are set up as described in
:ref:`set-up-channels`, your new package is installable by anyone using::

    conda install my-package-name

It is recommended that users set up channels as described in
:ref:`set-up-channels` to ensure that packages and dependencies are handled
correctly, and that they create an isolated environment when installing using
``conda create -n env-name-here``.
