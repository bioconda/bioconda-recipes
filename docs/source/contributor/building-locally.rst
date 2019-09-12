Testing Recipes Locally
=======================

Queue times on CircleCI may sometimes make it more convenient and
faster to work on complex packages locally. There are several ways to
do so, each with their own caveats.

.. contents::
   :local:


.. _circleci-client:

Using the Circle CI Client
~~~~~~~~~~~~~~~~~~~~~~~~~~

You can execute an almost exact copy of our Linux build pipeline by
`installing the CircleCI client locally
<https://circleci.com/docs/2.0/local-cli>`_ and running it from the
folder where your copy of ``bioconda-recipes`` resides::

    # Ensure the build container is up-to-date
    docker pull bioconda/bioconda-utils-build-env:latest

    # Run the build locally
    circleci build

You will have to have "commited" some changes as described above. The
command will run our build system just as it is run online in a docker
container. It will detect which recipes where modified using the
``git`` history and proceed with linting and building those.

Please note that this will only run the Linux build steps.


Using the "Bootstrap" Method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Due to technical limitations of the Circle CI client, the above test does
**not** run the more stringent ``mulled-build`` tests. To do so, use the
following commands:

.. code-block:: bash

    ./bootstrap.py /tmp/miniconda
    source ~/.config/bioconda/activate

    # optional linting
    bioconda-utils lint --git-range master

    # build and test
    bioconda-utils build --docker --mulled-test --git-range master

The above commands do the following:

- Install a separate miniconda installation in a temporary directory:
   - Set up bioconda channels,
   - install bioconda-utils dependencies into the root environment of
     that installation,
   - and write the file ``~/.config/bioconda/activate``
- Source that new file to specifically activate the root environment
  of the new installation
- Run ``bioconda-utils`` in the new installation:
   - The ``lint`` command will run the lint checks on your recipes
   - The ``build`` command will run the build pipeline

.. note::

   - You can select recipes to lint/build using ``--git-range master``,
     which which will select those recipes that have been changed
     between your master and your branch. Or you can specify recipes
     directly using ``--packages mypackage1 mypackage2``.
   - The ``--docker`` flag instructs ``bioconda-utils`` to execute the
     build within a docker container. On MacOS, this will do a Linux
     build in addition to the local MacOS build.
   - The ``--mulled-test`` flag instructs ``bioconda-utils`` to repeat
     the recipes test in a clean, freshly created docker container to
     ensure that the package does not depend on anything that happens
     to be included in the build container.

If you do not have access to Docker, you can still run the basic test by
telling the bootstrap setup to not use docker, and by excluding the
``--docker`` and ``--mulled-test`` arguments in the last command::

    ./bootstrap.py --no-docker /tmp/miniconda
    source ~/.config/bioconda/activate
    bioconda-utils build --git-range master


Using the "Debug" Method
~~~~~~~~~~~~~~~~~~~~~~~~

.. todo::

   - Explain how to use ``conda debug`` for difficult recipes.
   - Explain how to create patch series.
