.. bioconda documentation master file, created by
   sphinx-quickstart on Sat Nov  5 15:36:41 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. image:: bioconda.png

**Bioconda** is a channel for the `conda
<http://conda.pydata.org/docs/intro.html>`_  package manager specializing in
bioinformatics software. Bioconda consists of:

- a `repository of recipes <https://github.com/bioconda/bioconda-recipes>`_ hosted on GitHub
- a `build system <https://github.com/bioconda/bioconda-utils>`_ that turns these recipes into conda packages
- a `repository of more than 3000 bioinformatics packages
  <https://anaconda.org/bioconda/>`_ ready to use with ``conda install``
- Over 250 contributors that add, modify, update and maintain the recipes

The conda package manager makes installing software a vastly more
streamlined process. Conda is a combination of other package managers you may
have encountered, such as pip, CPAN, CRAN, Bioconductor, apt-get, and homebrew.
Conda is both language- and OS-agnostic, and can be used to install C/C++,
Fortran, Go, R, Python, Java etc programs on Linux, Mac OSX, and Windows.

Conda allows separation of packages into repositories, or `channels`.
The main `defaults` channel has a large number of common packages. Users can
add additional channels from which to install software packages not available
in the defaults channel. Bioconda is one such channel specializing in
bioinformatics software.

When using Bioconda please **cite our article** `Grüning, Björn, Ryan Dale, Andreas Sjödin, Brad A. Chapman, Jillian Rowe, Christopher H. Tomkins-Tinch, Renan Valieris, the Bioconda Team, and Johannes Köster. 2018. "Bioconda: Sustainable and Comprehensive Software Distribution for the Life Sciences". Nature Methods, 2018 <https://doi.org/10.1038/s41592-018-0046-7>`_.

Bioconda has been acknowledged by NATURE in their
`technology blog <http://blogs.nature.com/naturejobs/2017/11/03/techblog-bioconda-promises-to-ease-bioinformatics-software-installation-woes/>`_.

Each package added to Bioconda also has a corresponding Docker  `BioContainer
<https://biocontainers.pro>`_ automatically created and uploaded to Quay.io.

**Browse packages in the Bioconda channel:** :ref:`recipes`

**Browse BioContainer packages:** `Biocontainers Registry UI
<https://biocontainers.pro/registry/#/>`_

----

Bioconda is a derivative mark of Anaconda :sup:`®`, a trademark of Anaconda,
Inc registered in the U.S. and other countries.  Anaconda, Inc.
grants permission of the derivative use but is not associated with Bioconda.

The Bioconda channel is sponsored by `Anaconda, Inc <https://www.anaconda.com/>`_
in the form of providing unlimited (in time and space) storage.
Bioconda is supported by `Circle CI <https://circleci.com/>`_ via an open
source plan including free Linux and MacOS builds.


.. _using-bioconda:

Using Bioconda
==============
**Bioconda supports only 64-bit Linux and Mac OSX**.


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


.. _set-up-channels:

2. Set up channels
------------------

After installing conda you will need to add the bioconda channel as well as the
other channels bioconda depends on. **It is important to add them in this
order** so that the priority is set correctly (that is, bioconda is highest
priority).

The `conda-forge` channel contains many general-purpose packages not already
found in the `defaults` channel. The `r` channel is only included due to
backward compatibility.  It is not mandatory, but without the `r` channel
packages compiled against R 3.3.1 might not work.


::

    conda config --add channels defaults
    conda config --add channels conda-forge
    conda config --add channels bioconda


3. Install packages
-------------------
:ref:`Browse the packages <recipes>` to see what's available.

Bioconda is now enabled, so any packages on the bioconda channel can be installed into the current conda environment::

    conda install bwa

Or a new environment can be created::

    conda create -n aligners bwa bowtie hisat star


4. Join the team
----------------

Because our time is limited, the policy is to add a package if we need it ourselves.
However, we invite anybody who wants to use Conda for bioinformatics to
`join the team <https://github.com/bioconda/bioconda-recipes/issues/1>`_ and
contribute new packages. To get started, have a look at our
`recipes <https://github.com/bioconda/bioconda-recipes>`_ and the
`Conda documentation <http://conda.pydata.org/docs/building/recipe.html#conda-recipe-files-overview>`_.
If you don't want to join us permanently, you can also fork the
`recipes <https://github.com/bioconda/bioconda-recipes>`_ repository and create
pull requests.

5. Spread the word
------------------

Consider `adding a badge <_static/badge-generator/>`_ to your posters and presentations to promote
that a tool can be easily installed from Bioconda.


Contributors
============

Core
----

* `Johannes Köster <https://github.com/johanneskoester>`_
* `Ryan Dale <https://github.com/daler>`_
* `Brad Chapman <https://github.com/chapmanb>`_
* `Chris Tomkins-Tinch <https://github.com/tomkinsc>`_
* `Björn Grüning <https://github.com/bgruening>`_
* `Andreas Sjödin <https://github.com/druvus>`_
* `Jillian Rowe <https://github.com/jerowe>`_
* `Renan Valieris <https://github.com/rvalieris>`_
* `Marcel Bargull <https://github.com/mbargull>`_

Others
------
Bioconda has over 250 contributors, see `here <https://github.com/bioconda/bioconda-recipes/graphs/contributors>`_.


Contributor documentation
-------------------------

The rest of this documentation describes the build system architecture, the
process of creating and testing recipes, and adding recipes to the bioconda
channel.


Contents:

.. toctree::
    :maxdepth: 3

    recipes
    contributing
    linting
    faqs
    build-system
    cb3
    changes
