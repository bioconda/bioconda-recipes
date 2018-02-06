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
a `meta.yaml` file that defines these settings and a `build.sh` script that
builds the software. A recipe is converted into a *package* by running
`conda-build` on the recipe. A package is a bgzipped tar file (`.tar.bz2`) that
contains the built software. Packages are uploaded to anaconda.org so that
users can install them with `conda install`.

.. seealso::

    The `conda package specification <http://conda.pydata.org/docs/spec.html>`_
    has details on exactly what a package contains and how it is installed into
    an environment.

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

- `.circleci/config.yml` is read by the Circle CI worker.

- The worker runs `.circleci/setup.sh`. This installs conda, adds
  channels, and installs `bioconda-utils`

- The worker runs tests defined in `.circleci/config.yml`.

A local version of the Circle CI tests can be executed via the
:ref:`Circle CI client <circleci-client>`. Note that this version lacks some
additional tests that are executed in the online version. Thus, it can be that
a local test passes while the online test fails.
Nevertheless, the local test should capture most problems, such that it is highly
encouraged to first run a local test in order to save quota on Circle CI.

How are environmental variables defined and used?
-------------------------------------------------

In some cases a recipe may need to pin the version of a dependency.  Jinja2
templating is used within recipes to use a uniform set of versions for core
packages used by bioconda packages. For example, see this `meta.yaml
<https://github.com/bioconda/bioconda-recipes/blob/f5eb63e30a76fd13c28663786d219c9f7750267c/recipes/gfold/meta.yaml>`_
that uses a variable to hold the current GSL (GNU Scientific Library) version
supported by bioconda.

The currently defined dependencies are defined in `scripts/env_matrix.yml` and
are sent to `conda-build` by setting them as environment variables. More
specifically:

- `config.yml` indicates an `env_matrix` file in which CONDA_GSL is defined
    - `config.yaml` example
  <https://github.com/bioconda/bioconda-recipes/blob/0be2881ef95be68feb09fae7814e0217aca57285/config.yml#L1>`_ pointing to file

    - `env_matrix.yml` example
      <https://github.com/bioconda/bioconda-recipes/blob/0be2881ef95be68feb09fae7814e0217aca57285/scripts/env_matrix.yml>` defining CONDA_GSL.

- When figuring out which recipes need to be built, the filtering step attaches
  each unique env to a Target object. For example, one env might be
  `CONDA_GSL=1.6; CONDA_PY=27, CONDA_R=3.3.1;` while a different env would be
  `CONDA_GSL=1.6; CONDA_PY=35, CONDA_R=3.3.1;`.

- That env is provided to the build function which is either sent directly to
  docker as environment variables, or used to temporarily update os.environ so
  that conda-build sees it.

- These environment variables are then seen by conda-build and used to fill in
  the templated variables via jinja2.

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
  `conda install`.

Once uploaded to anaconda.org, it is our intention to never delete any old
packages. Even if a recipe in the bioconda repo is updated to a new version,
the old version will remain on anaconda.org. ContinuumIO has graciously agreed
to sponsor the storage required by the bioconda channel.
Nevertheless, it can sometimes happen that we have to mark packages as broken
in order to avoid that they are accidentally pulled by the conda solver.
In such a case it is only possible to install them by specifically considering
the `broken` label, i.e.,

.. code-block:: bash

    conda install -c bioconda -c conda-forge -c defaults -c bioconda/label/broken my-package=<broken-version>
