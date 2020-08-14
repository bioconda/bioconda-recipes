Contributing to Bioconda
========================

Bioconda is completely dependent on contributors to add, update, and
maintain recipes. Every little bit helps! Below are instructions for
one-time setup as well as a general procedure to follow for each
recipe you'd like to add.

The basic workflow is:

- Follow the :doc:`setup` instructions to get a local copy of the
  recipes repository

- Write a recipe or modify an existing one. A recipe consists of a
  metadata file and (optionally) a shell script to install it. Here is
  an example Python package:

    - `meta.yaml <https://github.com/bioconda/bioconda-recipes/blob/master/recipes/pyfaidx/meta.yaml>`_

- Push your changes to GitHub. This triggers automatic building and
  testing of the recipe.

- Once the tests pass, the recipe is reviewed by other members and
  then merged into the master branch. The resulting conda packages and
  containers that are built on the master branch are uploaded to
  public repositories for worldwide use.

There are some details to be aware of, and some software can be
challenging to package. The topics below provide more details.

.. toctree::
    :maxdepth: 1

    setup
    workflow
    building-locally

    troubleshooting
    build-system
    guidelines

    linting
    faqs
    updating
    cb3


