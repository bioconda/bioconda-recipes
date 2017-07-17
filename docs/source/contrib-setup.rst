
One-time setup
--------------


.. _github-setup:

Git and GitHub (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you are a bioconda team member (having been added by posting in issue #1),
then you have push access to the repo. In this case you can clone the
bioconda-recipes repo::

    git clone https://github.com/bioconda/bioconda-recipes.git

You can now move on to installing requirements (next section).

If you do not yet have push access, then fork the repo to your own account via
the GitHub site and then clone it locally::

    git clone https://github.com/<USERNAME>/bioconda-recipes.git

Then add the main bioconda-recipes repo as an upstream remote to more easily
update your branch with the upstream master branch::

    git remote add upstream https://github.com/bioconda/bioconda-recipes.git


Install Python requirements and Docker (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Install Python 3 if you do not already have it.

2. Install the `pyyaml` package, ``pip install pyyaml``. You may need "sudo" if
   you are using your system's default Python 3.

3. Install `Docker <https://www.docker.com/>`_. (optional, but allows you to
   simulate most closely the Travis-CI tests).

4. In the `bioconda-recipes` dir, run ``./simulate-travis.py --bootstrap
   <PATH>`` where ``<PATH>`` is the path to where you want the isolated conda
   to be installed. If this directory already exists, you can add the
   ``--force`` argument to overwrite its contents.

This last step does the following:

- downloads and installs Miniconda to the specified path
- adds a config file, ``~/.config/bioconda/conf.yml``, that records this
  specified path for future invocations of ``simulate-travis.py``
- sets the correct channel order
- installs dependencies for bioconda-utils

Please note that it is also required to build *any* recipe prior to using the
`simulate-travis.py` command as explained :ref:`here <test-locally>`.

Request to be added to the bioconda team
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
While not required, you can be added to the bioconda by posting in `Issue #1
<https://github.com/bioconda/recipes/issues/1>`_. Members of the bioconda team
can merge their own recipes once tests pass, though we ask that first-time
contributions and anything out of the ordinary be reviewed by the
@bioconda/core team.
