.. bioconda documentation master file, created by
   sphinx-quickstart on Sun Jan 31 13:31:02 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. highlight:: bash

========
Bioconda
========


.. image:: https://img.shields.io/github/watchers/bioconda/recipes.svg?style=social&label=Watch
   :target: https://github.com/bioconda/recipes/watchers

.. image:: https://img.shields.io/github/stars/bioconda/recipes.svg?style=social&label=Star
   :target: https://github.com/bioconda/recipes/stargazers

.. image:: https://img.shields.io/github/forks/bioconda/recipes.svg?style=social&label=Fork
   :target: https://github.com/bioconda/recipes/network

Bioconda is **a distribution of bioinformatics software realized as a channel
for the versatile Conda package manager**.
Key features of Conda are

* a command line client for simple installation and dependency handling in the spirit of ``conda install mypackage``,
* very easy package creation,
* a mechanism for creating isolated environments that allows different package versions to coexist.

These features turn Conda into the perfect package manager for bioinformatics,
where analyses often involve the application of various tools with sometimes
complicated and even conflicting dependencies or mixtures of different languages.
Ultimately, the usage of Conda should help to **perform reproducible science**.
Bioconda already contains **over 1500 bioinformatics related packages**.


.. _setup:

Setup and usage
===============

Requirements
------------

**Linux** (any distribution with GLIBC >=2.12) or **Max OS**.

Step 1: Install Conda
---------------------

To use bioconda, you need to install the **Conda package manager** which is most
easily obtained via the `Miniconda <http://conda.pydata.org/miniconda.html>`_
Python distribution. Miniconda can be installed to your home directory without admin priviledges.

Step 2: Setup Bioconda
--------------------------------------

After installing Miniconda, you can use the ``conda`` command to setup bioconda with::

   conda config --add channels conda-forge
   conda config --add channels defaults
   conda config --add channels r
   conda config --add channels bioconda

The ``r`` channel is added to satisfy the `R language <https://www.r-project.org/>`_
dependencies of some packages as well as some non-R dependencies.
Even if you don't plan on installing R packages, the `r` channel is required
for some Bioconda packages. Similarly, the ``conda-forge`` channel contains
many dependencies that are not strictly for bioinformatics but that are
required for Bioconda packages to work (see more at
`https://conda-forge.github.io`_).
Be sure to add the channels in the given order, because it defines how conda handles ambiguity between channels.
See `http://conda.pydata.org/docs/channels.html`_ for more information.

Step 3: Install packages or create environments
-----------------------------------------------

Once the channels have been added, you can install packages, e.g.::

   conda install bwa

Isolated environments (with e.g. specific software versions>`_ can be created via::

   conda create -n myenviroment bwa=0.7.12

For more information, visit the `Conda documentation <http://conda.pydata.org/docs>`_
or have a look at the command line options by executing::

   conda --help

Step 4: Join the team
---------------------

Because our time is limited, the policy is to add a package if we need it ourselves.
However, we invite anybody who wants to use Conda for bioinformatics to
`join the team <https://github.com/bioconda/bioconda-recipes/issues/1>`_ and
contribute new packages. To get started, have a look at our
`recipes <https://github.com/bioconda/bioconda-recipes>`_ and the
`Conda documentation <http://conda.pydata.org/docs/building/recipe.html#conda-recipe-files-overview>`_.
If you don't want to join us permanently, you can also fork the
`recipes <https://github.com/bioconda/bioconda-recipes>`_ repository and create
pull requests.

Step 5: Spread the word
---------------------

Consider `adding a badge <_static/badge-generator/>`_ to your posters and presentations to promote
that a tool can be easily installed from bioconda.


Contributors
============

Core
----

* `Johannes Köster <https://github.com/johanneskoester>`_
* `Ryan Dale <https://github.com/daler>`_
* `Brad Chapman <https://github.com/chapmanb>`_
* `Chris Tomkins-Tinch <https://github.com/tomkinsc>`_
* `Björn Grüning <https://github.com/bgruening>`_

Others
------
Bioconda has over 120 contributors, see `here <https://github.com/bioconda/bioconda-recipes/graphs/contributors>`_.

----

Bioconda is a derivative mark of Anaconda :sup:`®`, a trademark of Continuum Analytics, Inc registered in the U.S. and other countries.
Continuum Analytics, Inc. grants permission of the derivative use but is not associated with Bioconda.

The Bioconda channel is sponsored by `Continuum Analytics <https://www.continuum.io/>`_.


.. toctree::
   :hidden:
   :maxdepth: 1
   :glob:

   recipes/*/*
