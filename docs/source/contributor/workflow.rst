Contribution Workflow
+++++++++++++++++++++

The following steps are done for each recipe or batch of recipes you'd
like to contribute.

.. contents::
   :local:
   :backlinks: entry


.. _create_branch:

1. Create a Branch
~~~~~~~~~~~~~~~~~~

Next, we create a "branch". You could in theory work on the ``master``
branch, but it helps if you give the work you are intending to do a
name. That way you can more easily work on separate issues if one of
them turns out to be more complicated than you thought.

.. code-block:: bash

   # Make sure our master is up to date with Bioconda
   git checkout master
   git pull upstream master
   git push origin master

   # Create and checkout a new branch for our work
   git checkout -b update_my_recipe


.. _make_edits:

2. Make Some Edits
~~~~~~~~~~~~~~~~~~

Now you need to make your edits. Naturally, this can become rather
complex.

If you have a PyPi recipe you want to package for Bioconda, you could
start with the ``conda skeleton`` command creating a template
automatically::

  cd recipes
  conda skeleton pypi pyaml

(``pyaml`` is just an example. It would not be included in Bioconda as
it is a general purpose package. Those need to be added to
``conda-forge``, where ``pyaml`` is already present.)

Now edit the file(s) in the newly created folder (named according to
the package).

You can verify your edits by looking at the ``diff``::

  git diff

Or, you can have a look at the changed files and status of your repository using ``status``::

  git status


.. _push_changes:

3. Push Changes
~~~~~~~~~~~~~~~

To publish your changes, "add" them, then "commit" all added changes,
then push the branch to GitHub::

  # Choose the edited files to commit:
  git add pyaml
  # Create a commit (will open editor)
  git commit
  # Push your commit to GitHub
  git push


.. _create_pr:

4. Create a Pull Request
~~~~~~~~~~~~~~~~~~~~~~~~

Now head back to GitHub. Go to your fork of the ``bioconda-recipes``
repository and find the branch you have just created in the
``Branch:`` drop down. You should now see a message saying ``This
branch is 1 commit ahead [...] bioconda:master``. To the right of that
line you will find a button ``Pull Request``. Click this and follow
the instructions to open a new Pull Request.

If you get stuck, have a look at GitHub's own `About Pull Requests`_
documentation.

Once you have opened a PR, our build system will start testing your
changes. The recipes you have added or modified will be linted and
built. Unless you are very lucky, you will encounter some errors
during the build you will have to fix. Repeat :ref:`make_edits` and
:ref:`push_changes` as often as needed.

Eventually, your build will "turn green". If you are a member of
Bioconda, you can now add the ``please review & merge`` label to
submit your PR for review. Otherwise, just ask on `Gitter`_ or ping
``@bioconda/core``.

Once you changes have been approved, they will be "merged" into our
main repository and the altered packages uploaded to our channel.

.. _`About Pull Requests`: https://help.github.com/articles/about-pull-requests/
.. _`Gitter`: https://gitter.im/bioconda/lobby


.. _delete_branch:

5. Delete your Branch
~~~~~~~~~~~~~~~~~~~~~

Once the Pull Request has been merged, you can click ``Delete Branch``
directly on GitHub, or you can remove the branch with ``git``:

.. code-block:: bash

  # Delete local branch
  git branch -D my_branch
  # Delete branch in your fork via the remote named "origin"
  git push origin -d my_branch


6. Install Your Package
~~~~~~~~~~~~~~~~~~~~~~~

After the Pull Request has been merged, you will need to wait for a
little while for the package to become available. Our channel is so
popular that Anaconda decided to give us the "CDN treatment". While
this makes downloads faster, it means that updates to the Bioconda
channel take approximately a half hour to propagate. Once this has
happened, you can enjoy::

  conda install my-package

