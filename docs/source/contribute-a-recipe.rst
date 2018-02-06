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

The simplest way to conduct local tests is to :ref:`setup the Circle CI client <circleci-client>`.
Then, all that needs to be done is to execute

.. code-block:: bash

    circleci build

in the root of your repository clone.

Alternatively, you can manually run `conda build`, e.g.,

.. code-block:: bash

    conda build recipes/my-recipe

In this case. make sure to have setup Bioconda properly, see :ref:`using-bioconda`.
Also, you might need to manually specify environment variables that your recipe
uses, e.g., `CONDA_BOOST`. You can look up the proper values for those variables
under `scripts/env_matrix.yml` in the repository.


5. Push changes, wait for tests to pass, submit pull request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Push your changes to your fork or to the main repo (if using a clone) to GitHub::

    git push -u origin my-recipe

If using a fork, make sure to enable Circle CI for it under https://circleci.com/dashboard.

You can view the test status next to your commits in Github.
Make and push changes as needed to get the tests to pass.
Once they pass, create a `pull request
<https://help.github.com/articles/about-pull-requests/>`_ on the main bioconda
repo for your changes.
If

* it's your first recipe,
* the recipe is doing something non-standard or
* it adds a new package

please ask `@bioconda/core` for a review. If you are a member
of the bioconda team and none of above criteria apply, feel free to merge your
recipe once the tests pass.

6. Use your new recipe
~~~~~~~~~~~~~~~~~~~~~~
When the PR is merged with the master branch, Circle CI will again do the
builds but at the end will upload the packages to anaconda.org. Once this
completes, and as long as the channels are set up as described in
:ref:`set-up-channels`, your new package is installable by anyone using::

    conda install my-package-name

It is recommended that users set up channels as described in
:ref:`set-up-channels` to ensure that packages and dependencies are handled
correctly, and that they create an isolated environment when installing using
``conda create -n env-name-here``.
