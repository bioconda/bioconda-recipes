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


2. Write a recipe
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

3. Test locally
~~~~~~~~~~~~~~~

The simplest way to conduct local tests is to :ref:`setup the Circle CI client <circleci-client>`.
Then, all that needs to be done is to execute

.. code-block:: bash

    # Ensure the build container is up-to-date
    docker pull bioconda/bioconda-utils-build-env

    # Run the build locally
    circleci build

in the root of your repository clone.

Alternatively, you can manually run `conda-build`, e.g.,

.. code-block:: bash

    conda-build recipes/my-recipe

In this case. make sure to have setup Bioconda properly, see :ref:`using-bioconda`.
Also, you might need to manually specify environment variables that your recipe
uses, e.g., `CONDA_BOOST`. You can look up the proper values for those variables
under `scripts/env_matrix.yml` in the repository.


4. Push changes, wait for tests to pass, submit pull request
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

.. note::

    If you are first time user, you can't ask people specifically for a review (e.g. link @bioconda/core). 
    In this case, either ask to be added to the status of contributor (and then ask for a review by linking @bioconda/core) or just wait.

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
