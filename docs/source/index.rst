.. bioconda documentation master file, created by
   sphinx-quickstart on Sat Nov  5 15:36:41 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. image:: bioconda.png

Bioconda
========
**Bioconda** is a channel for the `conda
<http://conda.pydata.org/docs/intro.html>`_  package manager specializing in
bioinformatics software. Bioconda consists of:

- a `repository of recipes <https://github.com/bioconda/bioconda-recipes>`_ hosted on GitHub
- a `build system <https://github.com/bioconda/bioconda-utils>`_ that turns these recipes into conda packages
- a `repository of >1500 bioinformatics packages
  <https://anaconda.org/bioconda/>`_ ready to use with ``conda install``
- Over 130 contributors that add, modify, update and maintain the recipes

The conda package manager has recently made installing software a vastly more
streamlined process. Conda is a combination of other package managers you may
have encountered, such as pip, CPAN, CRAN, Bioconductor, apt-get, and homebrew.
Conda is both language- and OS-agnostic, and can be used to install C/C++,
Fortran, Go, R, Python, Java etc programs on Linux, Mac OSX, and Windows.

Conda allows separation of packages into separate repositories, or `channels`.
The main `defaults` channel has a large number of common packages. Users can
add additional channels from which to install software packages not available
in the defaults channel. Bioconda is one such channel specializing in
bioinformatics software.

.. _using-bioconda:

Using bioconda
==============
**bioconda supports only 64-bit Linux and Mac OSX**.


1. Install conda
----------------
Bioconda requires the conda package manager to be installed. If you have an
Anaconda Python installation, you already have it. Otherwise, the best way to
install it is with the `Miniconda <http://conda.pydata.org/miniconda.html>`_
package. The Python 3 version is recommended.

.. seealso::

    * :ref:`conda-anaconda-minconda`
    * The conda `FAQs <http://conda.pydata.org/docs/faq.html>`_ explain how
      it's easy to use with existing Python installations.

2. Set up channels
------------------

After installing conda you will need to add the bioconda channel as well as the
other channels bioconda depends on. **It is important to add them in this
order** so that the priority is set correctly (that is, bioconda is highest
priority).

The `conda-forge` channel contains many general-purpose packages not already
found in the `defaults` channel. The `r` channel contains common R packages
used as dependencies for bioconda packages.

::

    conda config --add channels conda-forge
    conda config --add channels defaults
    conda config --add channels r
    conda config --add channels bioconda


3. Install packages
-------------------

bioconda is now enabled, so any packages on the bioconda channel can be installed into the current conda environment::

    conda install bwa

Or a new environment can be created::

    conda create -n aligners bwa bowtie hisat star


4. Contribute!
--------------

The rest of this documentation describes the build system architecture, the
process of creating and testing recipes, and adding recipes to the bioconda
channel.


Contents:

.. toctree::
    :maxdepth: 2

    contributing
    faqs
    troubleshooting
    build-system
    guidelines

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

