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
Bioconda already contains **over 1000 bioinformatics related packages**.


.. _setup:

Setup and usage
===============

Step 1: Install Conda
---------------------

To use bioconda, you need to install the **Conda package manager** which is most
easily obtained via the `Miniconda <http://conda.pydata.org/miniconda.html>`_
Python distribution. Miniconda can be installed to your home directory without admin priviledges.

Step 2: Setup Bioconda
--------------------------------------

After installing Miniconda, you can use the ``conda`` command to setup bioconda with::

   conda config --add channels r
   conda config --add channels bioconda

The ``r`` channel is added to satisfy the `R language <https://www.r-project.org/>`_
dependencies of some packages as well as some non-R dependencies.
Even if you don't plan on installing R packages, the `r` channel is required
for some Bioconda packages.

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

Developers
==========

* `Johannes Köster <https://github.com/johanneskoester>`_
* `Hyeshik Chang <https://github.com/hyeshik>`_
* `Ryan Dale <https://github.com/daler>`_
* `David Koppstein <https://github.com/dkoppstein>`_
* `Brad Chapman <https://github.com/chapmanb>`_
* `Per Unneberg <https://github.com/percyfal>`_
* `Chris Tomkins-Tinch <https://github.com/tomkinsc>`_
* `Saulo Alves <https://github.com/sauloal>`_
* `Augustine (Gus) Dunn <https://github.com/xguse>`_
* `Rory Kirchner <https://github.com/roryk>`_
* `Will Dampier <https://github.com/JudoWill>`_
* `Luca Pinello <https://github.com/lucapinello>`_
* `Sebastian Luna Valero <https://github.com/sebastian-luna-valero>`_
* `Brant Faircloth <https://github.com/brantfaircloth>`_
* `Kyle Beauchamp <https://github.com/kyleabeauchamp>`_
* `Adam caprez <https://github.com/acaprez>`_
* `Alexey Strokach <https://github.com/ostrokach>`_
* `Brent Pedersen <https://github.com/brentp>`_
* `Guillermo Carrasco <https://github.com/guillermo-carrasco>`_
* `Yuri Pirola <https://github.com/yp>`_
* `Robin Andeer <https://github.com/robinandeer>`_
* `Måns Magnusson <https://github.com/moonso>`_
* `Lorena Pantano <https://github.com/lpantano>`_
* `Roman Valls Guimerà <https://github.com/brainstorm>`_
* `Vivek Rai <https://github.com/vivekiitkgp>`_
* `Zachary Charlop-Powers <https://github.com/zachcp>`_
* `Tiago Antao <https://github.com/tiagoantao>`_
* `Olga Botvinnik <https://github.com/olgabot>`_
* `Marcel Martin <https://github.com/marcelm>`_
* `Andreas Sjödin <https://github.com/druvus>`_
* `Joe Brown <https://github.com/brwnj>`_
* `Sahil Seth <https://github.com/sahilseth>`_
* `Ino de Bruijn <https://github.com/inodb>`_
* `Keith Simmon <https://github.com/kes1smmn>`_
* `Björn Grüning <https://github.com/bgruening>`_
* `Devon Ryan <https://github.com/dpryan79>`_
* `Miika Ahdesmaki <https://github.com/mjafin>`_
* `Christian Brueffer <https://github.com/cbrueffer>`_
* `Jerome Kelleher <https://github.com/jeromekelleher>`_
* `Thomas Cokelaer <https://github.com/cokelaer>`_
* `Dilmurat Yusuf <https://github.com/dyusuf>`_
* `Vince Yokois <https://github.com/vyokois>`_
* `Daniel Klevebring <https://github.com/dakl>`_
* `Dane Kennedy <https://github.com/kennedydane>`_
* `Alain Domissy <https://github.com/alaindomissy>`_
* `Sebastian Schmeier <https://github.com/sschmeier>`_
* `Saket Choudhary <https://github.com/saketkc>`_
* `Daniel Gaston <https://github.com/dgaston>`_
* `Joris van Steenbrugge <https://github.com/Jorisvansteenbrugge>`_
* `Gildas Le Corguillé <https://github.com/lecorguille>`_
* `Zhuoqing Fang <https://github.com/BioNinja>`_
* `Anthony Bretaudeau <https://github.com/abretaud>`_
* `Jillian Rowe <https://github.com/jerowe>`_
* `James Taylor <https://github.com/jxtx>`_
* `Bérénice Batut <https://github.com/bebatut>`_
* `Rémi Marenco <https://github.com/remimarenco>`_
* `Nitesh Turaga <https://github.com/nitesh1989>`_
* `Daniel Blankenberg <https://github.com/blankenberg>`_
* `Saskia Hiltemann <https://github.com/shiltemann>`_
* `Tom Smith <https://github.com/TomSmithCGAT>`_
* `Justin Fear <https://github.com/jfear>`_
* `Hai Nguyen <https://github.com/hainm>`_
* `Greg Von Kuster <https://github.com/gregvonkuster>`_
* `Florian Eggenhofer <https://github.com/eggzilla>`_
* `Sebastian Will <https://github.com/s-will>`_
* `Simon Ye <https://github.com/yesimon>`_
* `Simon van Heeringen <https://github.com/simonvh>`_
* `Kwangbom Choi <https://github.com/kbchoi-jax>`_
* `Dave Larson <https://github.com/ernfrid>`_
* `Henning Timm <https://github.com/HenningTimm>`_
* `Stephen J Newhouse <https://github.com/snewhouse>`_
* `Phil Ewels <https://github.com/ewels>`_

----

Bioconda is a derivative mark of Anaconda :sup:`®`, a trademark of Continuum Analytics, Inc registered in the U.S. and other countries.
Continuum Analytics, Inc. grants permission of the derivative use but is not associated with Bioconda.

The Bioconda channel is sponsored by `Continuum Analytics <https://www.continuum.io/>`_.


.. toctree::
   :hidden:
   :maxdepth: 1
   :glob:

   recipes/*/*
