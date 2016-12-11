
One-time setup
--------------

`conda-build`, which is required for building conda packages, must be
installed in the root environment, and the root environment must be Python
3. The dependencies for the build system also need to be installed in the
root environment.

.. _github-setup:

Git and GitHub (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Create a `fork <https://help.github.com/articles/fork-a-repo/>`_ of
  `bioconda-recipes on GitHub <https://github.com/bioconda/bioconda-recipes>`_
  and clone it locally. Even if you are a member of the bioconda team with push
  access, using your own fork will allow testing of your recipes on travis-ci
  using your own account's free resources without consuming resources allocated
  by travis-ci to the `bioconda` group. This makes the tests go faster for
  everyone::

    git clone https://github.com/<USERNAME>/bioconda-recipes.git

- Connect the fork to travis-ci, following steps 1 and 2 from the `travis-ci
  docs <https://docs.travis-ci.com/user/getting-started/#To-get-started-with-Travis-CI%3A>`_

- Add the main bioconda-recipes repo as an upstream remote to more easily
  update your branch with the upstream master branch::

    git remote add upstream https://github.com/bioconda/bioconda-recipes.git


Install conda and Docker (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Install `conda <http://conda.pydata.org/miniconda.html>`_. The Python
   3 version is required.

2. Install `Docker <https://www.docker.com/>`_. (optional, but allows you to
   simulate most closely the Travis-CI tests).


