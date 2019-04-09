.. _cb3-main:

Conda build v3
--------------

Conda build version 3 has lots of nice features that will make managing
packages in Bioconda much easier. However there are some changes that you will
need to be aware of, especially if you're used to making recipes using the old
conda-build v2 way.

This page documents each change and is intended to serve as a reference for the
transition.

.. _host-section:

The new ``host`` section
~~~~~~~~~~~~~~~~~~~~~~~~

**Summary:**

- Previously, build-time dependencies were listed in the ``requirements:build:`` section.
- Conda-build 3 now has an additional ``requirements:host:`` section. It is required if
  using compilers; otherwise old recipes can remain as-is and can be gradually
  ported over. New recipes should use the new ``host`` section as described
  below.

Due to the improved way compilers are now being handled (see
:ref:`compiler-tools`), the old build section is now split into two sections,
``build`` and ``host``. This change is largely to support cross-compiling,
which we are not doing yet. However if a recipe uses one of the new ``{{
compiler() }}`` methods described in :ref:`compiler-tools`, the ``host``
section is **required**.

The new ``build`` section should have things like compilers, ``git``,
``automake``, ``make``, ``cmake``, and other build tools. If there are no
compilers or other build tools, there should be no ``build:`` section.

The new ``host`` section should have everything else.

There are many existing recipes that only have a ``build:`` section. They will
work for now; they just won't work if we ever try to cross-compile them.
However **new** recipes should have the ``host:`` section.

The ``run`` section remains the same.

Before:

.. code-block:: yaml

    package:
      name: example
      version: 0.1
    requirements:
      build:
        - python
      run:
        - python

After:

.. code-block:: yaml

    package:
      name: example
      version: 0.1
    requirements:
      host:
        - python
      run:
        - python

.. seealso::

    See the `requirements section <conda-build:requirements>` of the
    conda docs for more info.


.. _compiler-tools:

Compiler tools
~~~~~~~~~~~~~~
**Summary:**

- Previously we used ``- gcc #[linux]`` and ``- llvm # [osx]`` for compilers
- Instead, we should use the syntax ``{{ compiler('c') }}``, ``{{
  compiler('cxx') }}``, and/or ``{{ compiler('fortran') }}``. These should go
  in the ``build`` section, and all other build dependencies should go in the
  ``host`` section.

Anaconda now provides platform-specific compilers that are automatically
determined. The string ``{{ compiler('c') }}`` will resolve to ``gcc`` on
Linux, but ``clang`` on macOS. This should greatly simplify recipes, as we no
longer need to have separate lines for linux and osx.

Note that previously we typically would also add ``- libgcc #[linux]`` as a run
dependency, but this is now taken care of by the compiler tools (see the global
pinning section below for more on this).

Conda-build 3 also now has the ability to cross-compile, making it now possible
to compile packages for macOS while running on Linux. To support this, recipes
must now make a distinction between dependencies that should be specific to the
building machine and dependencies that should be specific to the running
machine.

Dependencies specific to the building machine go in ``build``;
dependencies specific to the running machine go in ``host`` (see
:ref:`host-section`).


Before:

.. code-block:: yaml

    package:
      name: example
      version: 0.1
    requirements:
      build:
        - python
        - gcc  # [linux]
        - llvm # [osx]
      run:
        - python
        - libgcc  # [linux]

After:

.. code-block:: yaml

    package:
      name: example
      version: 0.1
    requirements:
      build:
        - {{ compiler('c') }}
      host:
        - python
      run:
        - python

.. seealso::

    - The `compiler tools <conda-build:compiler-tools>` section of the
      conda docs has much more info.

    - The default compiler options are defined by conda-build in the
      `variants.DEFAULT_COMPILERS
      <https://github.com/conda/conda-build/blob/master/conda_build/variants.py#L42>`_
      variable.

    - More details on "strong" and "weak" exports (using examples of
      libpng and libgcc) can be found in the `export runtime
      requirements <conda-build:run_exports>` conda documentation.


.. warning::

    These compilers are only available in the ``defaults`` channel. Until now
    we have not had this channel as a dependency, so be sure to add the channel
    when setting up bioconda (see :ref:`set-up-channels`).

.. _global-pinning:

Global pinning
~~~~~~~~~~~~~~

**Summary:**

- Previously we pinned packages using the syntax ``- zlib {{ CONDA_ZLIB }}*``
  in both the ``build`` and ``run`` dependencies.
- Instead, we should now specify only package names in the ``host`` and ``run``
  sections e.g., as simply ``zlib``. They are pinned automatically.

Global pinning is the idea of making sure all recipes use the same versions of
common libraries.  Problems arise when the build-time version does not match
the install-time version. Furthermore, all packages installed into the same
environment should have been built using the same version so that they can
co-exist. For example, many bioinformatics tools have ``zlib`` as a dependency.
The version of ``zlib`` used when building the package should be the same as the
version used when installing the package into a new environment. This implies
that we need to specify the ``zlib`` version in one place and have all recipes
use that version.

Previously we maintained a global, bioconda-specific pinning file (see
`scripts/env_matrix.yaml
<https://github.com/bioconda/bioconda-recipes/blob/dd7248c5dcc5ea0237c81bff4d1e6df5a9bdd274/scripts/env_matrix.yml>`_).
For ``zlib``, that file defined the variable ``CONDA_ZLIB`` and that variable
was made available to the recipes as a jinja2 variable. One problem with this
is that we did not often synchronize our pinned versions with conda-forge's
pinned versions, and this disconnect could cause problems.

There are two major advances in conda-build 3 to address these problems. First
is the concept of "variants". Variants are a generalized way of specifying one
or more specific versions, and they come with many weird and wonderful ways to
specify constraints. Specifying variants generally takes the form of writing
a YAML file. We have adopted the variants defined by conda-forge by installing
their `conda-forge-pinning` conda package in our build environment.
Technically, that package unpacks the config YAML into our conda environment so
that it can be used for building all recipes. You can see this file at
`conda_build_config.yaml
<https://github.com/conda-forge/conda-forge-pinning-feedstock/blob/master/recipe/conda_build_config.yaml>`_.

The second major advance in conda-build 3 is the the concept of "run exports".
The idea here is to specify that any time a dependency (``zlib``, in our running example)
is used as a build dependency, it should also be automatically be installed as
a run dependency without having to explicitly add it as such in the recipe.
This specification is done in the ``zlib`` recipe itself (which is hosted by
conda-forge), so in general bioconda collaborators can just add ``zlib`` as
a build dependency.

Note that we don't have to specify the version of ``zlib`` in the recipe -- it
is pinned in that ``conda_build_config.yaml`` file we share with conda-forge.

In a similar fashion, the reason that we no longer have to specify ``libgcc``
as a run dependency (as described above in the compilers section) is that ``{{
compiler('c') }}`` automatically export ``libgcc`` as a run dependency.

Before:

.. code-block:: yaml

    package:
      name: example
      version: 0.1
    requirements:
      build:
        - python
        - gcc  # [linux]
        - llvm  # [osx]
        - zlib {{ CONDA_ZLIB }}*
      run:
        - python
        - libgcc  # [linux]
        - zlib {{ CONDA_ZLIB }}*

After:

.. code-block:: yaml

    package:
      name: example
      version: 0.1
    requirements:
      build:
        - {{ compiler('c') }}
      host:
        - python
        - zlib
      run:
        - python
        - zlib


.. seealso::

    The `conda-build:resources/variants` section of the conda docs has
    much more information.

    We share the packages pinned by conda-forge, which can be found in their
    `conda_build_config.yaml
    <https://github.com/conda-forge/conda-forge-pinning-feedstock/blob/master/recipe/conda_build_config.yaml>`_

    Bio-specific packages additionally pinned by bioconda can be found at
    ``bioconda_utils-conda_build_config.yaml`` in the bioconda-utils source.
