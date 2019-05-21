One-time setup
--------------

.. _github-setup:

Git and GitHub (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are a bioconda team member then you have push access to the
repo. In this case you can clone the bioconda-recipes repo.

Decide whether you'll work on a clone or a fork.

Choose a clone if:

- You are a bioconda team member. Team members have write access to branches
  other than the master and bulk branches.

Choose a fork if:

- you are not yet a member of the bioconda team
- you expect to do lots of testing or lots of troubleshooting. This will allow
  you to use your own quota on Circle CI, so your builds will likely happen
  faster and you won't be consuming the limited bioconda quota.

Using a clone
+++++++++++++

Clone the main repo::

    git clone https://github.com/bioconda/bioconda-recipes.git


You can now move on to installing requirements (next section).

Using a fork
++++++++++++

If you do not have push access (see above), then create a `fork
<https://help.github.com/articles/fork-a-repo/>`_ of `bioconda-recipes on
GitHub <https://github.com/bioconda/bioconda-recipes>`_. Then clone it
locally::

    git clone https://github.com/<USERNAME>/bioconda-recipes.git

Then add the main bioconda-recipes repo as an upstream remote to more easily
update your branch with the upstream master branch::

    cd bioconda-recipes
    git remote add upstream https://github.com/bioconda/bioconda-recipes.git

.. _circleci-client:

Install the Circle CI client (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Queue times on CircleCI may sometimes make it more convenient and
faster to work on complex packages locally. You can execute an almost
exact copy of our Linux build pipeline by `installing the CircleCI client
locally <https://circleci.com/docs/2.0/local-cli>`_ and running it
from the folder where your copy of **bioconda-recipes** resides::

    circleci build

Should you encounter "weird" errors, try updating your local copy
of the build environment image::

    docker pull bioconda/bioconda-utils-build-env:latest
    
If the error persists, ask for help on our
`Gitter channel <https://gitter.im/bioconda/Lobby>`_ and/or file an 
issue at
`bioconda-utils <https://github.com/bioconda/bioconda-utils>`_.


Request to be added to the bioconda team (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
While not required, you can be added to bioconda by pinging @bioconda/core in 
a pull request. Members of the bioconda team can merge their own recipes
once linting and testing steps.
