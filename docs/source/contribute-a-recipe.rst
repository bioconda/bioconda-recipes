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

*Updated April 2018 to describe the bootstrap.py method*

There are currently two options for local testing: 1) using the Circle CI
client and 2) setting up a separate Miniconda installation and running
bioconda-utils. The first is probably more straightforward; the second is more
stringent, can be used for testing on MacOS, and allows the full customization
of the bioconda-utils calls.

.. _cci_clent:

Circle CI client method
+++++++++++++++++++++++
The simplest way to conduct local tests is to :ref:`setup the Circle CI client
<circleci-client>`. Then run the following commands:

.. code-block:: bash

    # Ensure the build container is up-to-date
    docker pull bioconda/bioconda-utils-build-env

    # Run the build locally
    circleci build

in the root of your repository clone. This command effectively runs the recipe
linting and then  ``conda build`` on all recipes recently changed. It does so
in an environment with properly configured channels and environment variables
in ``scripts/env.yaml`` exported into the build environment. The latter allows
``conda build`` to fill in variables in recipes like ``CONDA_BOOST`` that
otherwise wouldn't work with a simple ``conda build`` directly from the command
line.


.. _bootstrap:

"Bootstrap" method
++++++++++++++++++
Due to technical limitations of the Circle CI client, the above test does
**not** run the more stringent ``mulled-build`` tests. To do so, use the
following commands:

.. code-block:: bash

    ./bootstrap.py /tmp/miniconda
    source ~/.config/bioconda/activate

    # optional linting
    bioconda-utils lint recipes config.yml --git-range master

    # build and test
    bioconda-utils build recipes config.yml --docker --mulled-test --git-range master

The above commands do the following:

- install a separate miniconda installation in a temporary directory, set up
  bioconda channels, install bioconda-utils dependencies into the root
  environment of that installation, and write the file
  ``~/.config/bioconda/activate``
- source that new file to specifically activate the root environment of that
  new installation
- run bioconda-utils in that new installation

If you do not have access to Docker, you can still run the basic test by
telling the bootstrap setup to not use docker, and by excluding the
``--docker`` and ``--mulled-test`` arguments in the last command:

.. code-block:: bash

    ./bootstrap.py --no-docker /tmp/miniconda
    source ~/.config/bioconda/activate
    bioconda-utils build recipes config.yml --git-range master


4. Push changes, wait for tests to pass, submit pull request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Push your changes to your fork or to the main repo (if using a clone) to GitHub::

    git push -u origin my-recipe

.. note::

    **Update March 2018:** If using a fork, please do not enable Circle CI for it.
    If you have enabled CircleCI to build your fork in the past, please disable it
    under https://circleci.com/dashboard (look for the big red "Stop Building"
    button). See :ref:`circlecimacos` for more details.

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

    If you are a first time user, you can't ask people specifically for a review (e.g. link @bioconda/core). 
    In this case, either ask to be added to the status of contributor [here](https://github.com/bioconda/bioconda-recipes/issues/1) (and then ask for a review by linking @bioconda/core) or just wait.

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
