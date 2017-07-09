
One-time setup
--------------


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
  docs
  <https://docs.travis-ci.com/user/getting-started/#To-get-started-with-Travis-CI%3A>`_

- Add the main bioconda-recipes repo as an upstream remote to more easily
  update your branch with the upstream master branch::

    git remote add upstream https://github.com/bioconda/bioconda-recipes.git


Install conda and Docker (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Currently, you need to install the requirements (see below) into the root
conda environment which must be a Python 3 environment.

1. Install `conda <http://conda.pydata.org/miniconda.html>`_. The Python
   3 version is required.

2. Install `conda-build <https://conda.io/docs/building/recipe.html>`_. Note
   that the installation must be done from the root `conda` environment, so you
   will need to `source deactivate` your current environment. If you'd like to
   read an extensive discussion about `conda` and root vs default environments,
   check out `this discussion <https://github.com/conda/conda/issues/1145>`_

3. Install `Docker <https://www.docker.com/>`_. (optional, but allows you to
   simulate most closely the Travis-CI tests).

Please note that it is also required to build *any* recipe prior to using the
`simulate-travis.py` command as explained :ref:`here <test-locally>`.

Request to be added to the bioconda team
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
While not required, you can be added to the bioconda by posting in `Issue #1
<https://github.com/bioconda/recipes/issues/1>`_. Members of the bioconda team
can merge their own recipes once tests pass, though we ask that first-time
contributions and anything out of the ordinary be reviewed by the
@bioconda/core team.
