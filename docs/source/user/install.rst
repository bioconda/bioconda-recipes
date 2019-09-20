.. _using-bioconda:

Getting Started
===============
**Note:** *Bioconda supports only 64-bit Linux and Mac OS*.


1. Install conda
----------------

Bioconda requires the conda package manager to be installed. If you
have an Anaconda Python installation, you already have it. Otherwise,
the best way to install it is with the `conda.io:miniconda`
package. The Python 3 version is recommended.


On MacOS, run::

   wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
   sh Miniconda3-latest-MacOSX-x86_64.sh

On Linux, run::

   wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
   sh Miniconda3-latest-Linux-x86_64.sh

Follow the instructions in the installer. If you encounter problems,
refer to the `conda.io:miniconda` documentation. You can also join our
Gitter_ channel to ask other users for help.


.. seealso::

    * :ref:`conda-anaconda-minconda`
    * The conda `FAQs <https://docs.anaconda.com/anaconda/user-guide/faq/>`_ explain how
      it's easy to use with existing Python installations.


.. _set-up-channels:

2. Set up channels
------------------

After installing conda you will need to add the bioconda channel as well as the
other channels bioconda depends on. **It is important to add them in this
order** so that the priority is set correctly (that is, conda-forge is highest
priority).

The `conda-forge`_ channel contains many general-purpose packages not already
found in the ``defaults`` channel.


::

    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge

.. _`conda-forge`: https://conda-forge.org


3. Install packages
-------------------
:ref:`Browse the packages <recipes>` to see what's available.

Bioconda is now enabled, so any packages on the bioconda channel can be installed into the current conda environment::

    conda install bwa

Or a new environment can be created::

    conda create -n aligners bwa bowtie hisat star


4. Join the team
----------------

We invite all parties interested in adding/editing package recipes to join the bioconda team, 
so that their pull requests don't require merging by the core team or other members. To do 
so, please fork our `recipes <https://github.com/bioconda/bioconda-recipes>`_ have a read 
through the `Conda documentation <https://docs.conda.io/projects/conda-build/en/latest/concepts/recipe.html>`_. 
If you ping ``@bioconda/core`` in a pull request we will review it and then add you to the team, if you desire.

5. Spread the word
------------------

Consider `adding a badge <../_static/badge-generator/>`_ to your posters and presentations to promote
that a tool can be easily installed from Bioconda.


.. .. _`Miniconda`: http://conda.pydata.org/miniconda.html
.. _`Gitter`: https://gitter.im/bioconda/lobby
