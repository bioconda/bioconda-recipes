Contributing
============

Bioconda is completely dependent on contributors to add, update, and maintain
recipes. Every little bit helps! Below are instructions for one-time setup as
well as a general procedure to follow for each recipe you'd like to add.

The basic workflow is:

- Follow the setup instructions to get a local copy of the recipes repository

- Write a recipe or modify an existing one. A recipe consists of a metadata
  file and a shell script to install it. Here is an example Python package:

    - `meta.yaml <https://github.com/bioconda/bioconda-recipes/blob/master/recipes/pyfaidx/meta.yaml>`_
    - `build.sh <https://github.com/bioconda/bioconda-recipes/blob/master/recipes/pyfaidx/build.sh>`_

- Push your changes to github. This triggers automatic building and testing of
  the recipe.

- Once the tests pass, the recipe is merged into the master branch. The
  resulting conda packages and containers that are built on the master branch
  are uploaded to public repositories for worldwide use.

There are some details to be aware of, and some software can be challenging to
package. The topics below provide more details.

.. toctree::
    :maxdepth: 2

    contrib-setup
    contribute-a-recipe
    troubleshooting
    build-system
    guidelines


