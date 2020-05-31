Initial Setup
=============

Bioconda employs the "standard" GitHub Fork & Pull Request workflow
for edits to the collection of recipes from which the packages are
built.

To get started, you need to get yourself a copy of our recipes
repository.

.. contents::
   :local:


1. Create a Fork of our Recipes Repo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Click `here <https://github.com/bioconda/bioconda-recipes/fork>`_ to
create a "fork" of our recipes repository (if you haven't already). A
"fork" is essentially a copy of a repository in your own account where
you will be able to make edits. GitHub will remember where it came
from, so you will be able to feed your edits back to us (called Pull
Requests).

.. Note::

   Bioconda members may create branches directly in the
   ``bioconda/bioconda-recipes`` repository. Please try to remember to
   delete branches once you are done with them if you do so.


2. Create Local "Clone"
~~~~~~~~~~~~~~~~~~~~~~~

To start working on a recipe (new or existing), you first need to get
a local copy of the repo on your computer. Make sure you have ``git``
installed, and then run::

  git clone https://github.com/<USERNAME>/bioconda-recipes.git

This will create a folder ``bioconda-recipes``. To be able to update
this folder more easily with changes made to our repository, add
the main bioconda-recipes repo as an upstream remote::

    cd bioconda-recipes
    git remote add upstream https://github.com/bioconda/bioconda-recipes.git


3. Continue with or without local builds
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Continue reading `workflow` to learn how to make changes to recipes
  and get packages into our channel.
- Have a look at `building-locally` to learn how to build and debug
  packages on your own computer.
