One-time setup
--------------

.. _github-setup:

Git and GitHub (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Decide whether you'll work on a clone or a fork.

Choose a clone if:

- You are a bioconda team member (post on `issue #1
  <https://github.com/bioconda/bioconda-recipes/issues/1>`_ if you'd like to
  join). Team members have write access to branches other than the master
  branch.

- You want to have other team members make changes directly to your branch

Choose a fork if:

- you are not yet a member of the bioconda team
- you expect to do lots of testing or lots of troubleshooting. This will allow
  you to use your own quota on travis-ci, so your builds will likely happen
  faster and you won't be consuming limited bioconda quota.

Using a clone
+++++++++++++

Clone the main repo::

    git clone https://github.com/bioconda/bioconda-recipes.git

Using a fork
++++++++++++

- Create a `fork <https://help.github.com/articles/fork-a-repo/>`_ of
  `bioconda-recipes on GitHub <https://github.com/bioconda/bioconda-recipes>`_
  and clone it locally::

    git clone https://github.com/<USERNAME>/bioconda-recipes.git

- Connect the fork to travis-ci, following steps 1 and 2 from the `travis-ci
  docs
  <https://docs.travis-ci.com/user/getting-started/#To-get-started-with-Travis-CI%3A>`_

- Add the main bioconda-recipes repo as an upstream remote to more easily
  update your branch with the upstream master branch::

    git remote add upstream https://github.com/bioconda/bioconda-recipes.git


Install Docker (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~
Installing `Docker <https://www.docker.com/>`_ is optional, but allows you to
simulate most closely the Travis-CI tests.

Request to be added to the bioconda team (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
While not required, you can be added to the bioconda by posting in `Issue #1
<https://github.com/bioconda/recipes/issues/1>`_. Members of the bioconda team
can merge their own recipes once tests pass, though we ask that first-time
contributions and anything out of the ordinary be reviewed by the
@bioconda/core team.
