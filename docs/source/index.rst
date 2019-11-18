.. image:: bioconda.png

**Bioconda** is a channel for the conda_ package manager
specializing in bioinformatics software. Bioconda consists of:

- a `repository of recipes`_ hosted on GitHub
- a `build system`_ turning these recipes into conda packages
- a `repository of packages`_ containing over 6000 bioinformatics
  packages ready to use with ``conda install``
- over 600 contributors and 500 members who add, modify, update and
  maintain the recipes

.. _conda: https://conda.io/en/latest/index.html
.. _`repository of recipes`: https://github.com/bioconda/bioconda-recipes
.. _`build system`: https://github.com/bioconda/bioconda-utils
.. _`repository of packages`: https://anaconda.org/bioconda/

The conda package manager makes installing software a vastly more
streamlined process. Conda is a combination of other package managers
you may have encountered, such as pip, CPAN, CRAN, Bioconductor,
apt-get, and homebrew.  Conda is both language- and OS-agnostic, and
can be used to install C/C++, Fortran, Go, R, Python, Java etc
programs on Linux, Mac OSX, and Windows.

Conda allows separation of packages into repositories, or ``channels``.
The main ``defaults`` channel has a large number of common
packages. Users can add additional channels from which to install
software packages not available in the defaults channel. Bioconda is
one such channel specializing in bioinformatics software.

**Browse packages in the Bioconda channel:** `Recipe Index <conda-recipe_index.html>`_

Each package added to Bioconda also has a corresponding Docker
`BioContainer`_ automatically created and uploaded to `Quay.io`_. A
list of these and other containers can be found at the `Biocontainers
Registry`_.

.. _`BioContainer`: https://biocontainers.pro
.. _`Quay.io`: https://quay.io/organization/biocontainers
.. _`BioContainers Registry`: https://biocontainers.pro/#/registry

News
====

* Nov 2019: Bioconda has been selected as one of 32 open source projects for being `funded by the Chan Zuckerberg Initiative <https://chanzuckerberg.com/newsroom/chan-zuckerberg-initiative-awards-5-million-for-open-source-software-projects-essential-to-science>`_.
* Nov 2017: Bioconda has been acknowledged by NATURE in their `technology blog`_.

.. _`technology blog`: http://blogs.nature.com/naturejobs/2017/11/03/techblog-bioconda-promises-to-ease-bioinformatics-software-installation-woes

Citing Bioconda
===============

When using Bioconda please **cite our article**:

  Grüning, Björn, Ryan Dale, Andreas Sjödin, Brad A. Chapman, Jillian
  Rowe, Christopher H. Tomkins-Tinch, Renan Valieris, the Bioconda
  Team, and Johannes Köster. 2018. "Bioconda: Sustainable and
  Comprehensive Software Distribution for the Life Sciences". Nature
  Methods, 2018 doi::doi:`10.1038/s41592-018-0046-7`.

Acknowledgments
===============

Bioconda is a derivative mark of Anaconda :sup:`®`, a trademark of Anaconda,
Inc registered in the U.S. and other countries.  Anaconda, Inc.
grants permission of the derivative use but is not associated with Bioconda.

The Bioconda channel is sponsored by `Anaconda, Inc <https://www.anaconda.com/>`_
in the form of providing unlimited (in time and space) storage.
Bioconda is supported by `Circle CI <https://circleci.com/>`_ via an open
source plan including free Linux and MacOS builds.

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
* `Devon Ryan <https://github.com/dpryan79>`_
* `Elmar Pruesse <https://github.com/epruesse>`_

Team
----

Bioconda has over 600 (as of 2019/1) `contributors
<https://github.com/bioconda/bioconda-recipes/graphs/contributors>`_.


Table of contents
=================

.. toctree::
   :includehidden:

   user/index
   contributor/index
   developer/index
