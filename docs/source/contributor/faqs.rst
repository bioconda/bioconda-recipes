FAQs
====
This section is to help contributors get up to speed on various topics related
to building and testing conda packages.

.. _conda-anaconda-minconda:

What's the difference between Anaconda, conda, and Miniconda?
-------------------------------------------------------------

The `Anaconda Python distribution <https://www.continuum.io/downloads>`_
started out as a bundle of scientific Python packages that were otherwise
difficult to install. It was created by `ContinuumIO
<https://www.continuum.io/>`_ and remains the easiest way to install the full
scientific Python stack.

Many packaging problems had to be solved in order to provide a cross-platform
bundle, and one of the tools that came out of that work was the conda package
manager. So conda is part of Anaconda. But conda ended up being very useful on
its own and for things other than Python, so ContinuumIO spun it out into its
own separate `open-source package <https://github.com/conda/conda>`_.

However, conda is not just for Python, it is not "pip-installable" and rather
needs to be installed in a language-agnostic manner. The conda installer is
called Miniconda, to differentiate it from the full-size Anaconda.

So: conda is a package manager, Miniconda is the conda installer, and Anaconda
is a scientific Python distribution that also includes conda.

Recipe vs package
-----------------

A *recipe* is a directory containing small set of files that defines name,
version, dependencies, and URL for source code. A recipe typically contains
a ``meta.yaml`` file that defines these settings and a ``build.sh`` script that
builds the software. A recipe is converted into a *package* by running
`conda-build` on the recipe. A package is a bgzipped tar file (``.tar.bz2``) that
contains the built software. Packages are uploaded to anaconda.org so that
users can install them with ``conda install``.

.. seealso::

    The `conda-build:resources/package-spec` has details on exactly
    what a package contains and how it is installed into an
    environment.

Continuous integration (Circle CI)
----------------------------------
We use the Circle CI continuous integration service. Continuous integration
tests each small incremental change to code to ensure that everything is
up-to-date and correct. Circle CI graciously provides this service for free to
open-source projects. It is connected to GitHub such that each time a pull
request or merge occurs, a new Circle CI build is created. For bioconda,
a "build" means identifying any recipes that need to built, running
`conda-build` on them, and testing to make sure they work.

How is Circle CI set up and configured?
---------------------------------------

- ``.circleci/config.yml`` is read by the Circle CI worker.

- The worker runs ``.circleci/setup.sh``. This installs conda, adds
  channels, and installs :doc:`../developer/bioconda-utils`

- The worker runs tests defined in ``.circleci/config.yml``.

A local version of the Circle CI tests can be executed via the
:ref:`Circle CI client <circleci-client>`. Note that this version lacks some
additional tests that are executed in the online version. Thus, it can be that
a local test passes while the online test fails.
Nevertheless, the local test should capture most problems, such that it is highly
encouraged to first run a local test in order to save quota on Circle CI.

How are dependencies pinned to particular versions?
---------------------------------------------------

In some cases a recipe may need to pin the version of a dependency.
A global set of default versions to pin against is shared with conda-forge and
can be found `here <https://github.com/conda-forge/conda-forge-pinning-feedstock/blob/master/recipe/conda_build_config.yaml>`_.
For new dependencies that are contained in conda-forge and not yet in this list,
please update the list via a pull request.
Local pinnings can be achieved by adding a file ``conda_build_config.yaml`` next
to your ``meta.yaml``.

To find out against which version you can pin a package, e.g. x.y.* or x.* please use `ABI-Laboratory <https://abi-laboratory.pro/tracker/>`_.

What's the lifecycle of a bioconda package?
-------------------------------------------

- Submit a pull request with a new recipe or an updated recipe
- Circle CI automatically builds and tests the changed recipe[s] using
  conda-build. Test results are shown on the PR.
- If tests fail, push changes to PR until they pass.
- Once tests pass, merge into master branch
- Circle CI tests again, but this time after testing the built packages are
  uploaded to the bioconda channel on anaconda.org.
- Users can now install the package just like any other conda package with
  ``conda install``.

Once uploaded to anaconda.org, it is our intention to never delete any old
packages. Even if a recipe in the bioconda repo is updated to a new version,
the old version will remain on anaconda.org. ContinuumIO has graciously agreed
to sponsor the storage required by the bioconda channel.
Nevertheless, it can sometimes happen that we have to mark packages as broken
in order to avoid that they are accidentally pulled by the conda solver.
In such a case it is only possible to install them by specifically considering
the ``broken`` label, i.e.,

.. code-block:: bash

    conda install -c conda-forge -c bioconda -c defaults -c bioconda/label/broken my-package=<broken-version>


.. _circlecimacos:

CircleCI macOS plans
--------------------
In the past we had recommended enabling CircleCI for your fork to help conserve
the bioconda team's build time quota. However this did not work very well:
macOS builds on CircleCI require an extra macOS plan, which is not free to
users. The result was that contributors' pull requests would fail tests simply
due to not having a paid macOS plan. Luckily, CircleCI has generously provided
macOS builds to the bioconda team.

To ensure that CircleCI uses the bioconda team account, please **disable**
CircleCI on your fork (look for the big red "Stop Building" button at
https://circleci.com/dashboard under the settings for your fork).

Testing ``bioconda-utils`` locally
----------------------------------

Follow the instructions at :ref:`bootstrap` to create a separate Miniconda
installation using the ``bootstrap.py`` script in the ``bioconda-recipes`` repo.

Then, in the activated environment, install the bioconda-utils test
requirements, from the top-level directory of the ``bioconda-utils`` repo.
While the bootstrap script installs bioconda-utils dependencies, if there are
any changes in ``requirements.txt`` you will want to install them as well.

The bootstrap script already installed bioconda-utils, but we want to install
it in develop mode so we can make local changes and they will be immediately
picked up. So we need to uninstall and then reinstall bioconda-utils.

Finally, run the tests using ``pytest``.

In summary:

.. code-block:: bash

    # activate env
    source ~/.config/bioconda/activate

    # install dependencies
    conda install --file test-requirements.txt --file bioconda_utils/bioconda_utils-requirements.txt

    # uninstall and then reinstall
    pip uninstall bioconda_utils
    python setup.py develop

    # run tests
    pytest test -vv

Where can I find more info on ``meta.yaml``?
--------------------------------------------

The ``meta.yaml`` file is conda's metadata definition file for recipes. 
If you are developing a new recipe or are trying to update or improve an existing one, it can be helpful to know  
which elements and values can appear in ``meta.yaml``.

Conda has this information available `here <https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html>`_.
Please check that you are looking at the correct version of the documentation for the current conda version used by bioconda. 
