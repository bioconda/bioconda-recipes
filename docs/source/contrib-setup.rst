One-time setup
--------------

.. _github-setup:

Git and GitHub (one-time setup)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you are a bioconda team member (having been added by posting in issue #1),
then you have push access to the repo. In this case you can clone the
bioconda-recipes repo::

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
  you to use your own quota on Circle CI, so your builds will likely happen
  faster and you won't be consuming limited bioconda quota.

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

    git remote add upstream https://github.com/bioconda/bioconda-recipes.git

.. _circleci-client:

Install the Circle CI client (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is optional in the sense that you can still contribute without it, but
installing the Circle CI client allows you to test your recipes before pushing
them by simulating the online Circle CI tests locally. Resolving problems
locally before pushing changes will conserve online build time and quota.

Installation instructions can be found `here
<https://circleci.com/docs/2.0/local-cli/#installing-the-circleci-local-cli-on-macos-and-linux-distros>`_.

.. note::

    For contributors who have used ``simulate-travis.py`` for local testing:
    our move from Travis-CI to Circle CI means that ``simulate-travis.py`` is
    now deprecated.

    Instead of ``simulate-travis.py``, please install the Circle CI client and
    run ``circleci build``.

Request to be added to the bioconda team (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
While not required, you can be added to the bioconda by posting in `Issue #1
<https://github.com/bioconda/recipes/issues/1>`_. Members of the bioconda team
can merge their own recipes once tests pass, though we ask that first-time
contributions and anything out of the ordinary be reviewed by the
@bioconda/core team.
