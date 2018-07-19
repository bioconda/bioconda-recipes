from textwrap import dedent
import tempfile
import yaml
import os
import subprocess as sp


def ensure_missing(package):
    """
    Delete a package if it exists and re-index the conda-bld dir.

    If a package is deleted from the conda-bld directory but conda-index is not
    re-run, it remains in the metadata (.index.json, repodata.json) files and
    appears to conda as if the recipe still exists.  This ensures that the
    package is deleted and is removed from the index. Useful for test cases.

    Parameters
    ----------
    package : str
        Path to tarball of built package. If all you have is a recipe path, use
        `built_package_path()` to get the tarball path.
    """
    if os.path.exists(package):
        os.unlink(package)
    assert not os.path.exists(package)
    sp.check_call(['conda', 'index', os.path.dirname(package)])


class Recipes(object):
    def __init__(self, data, from_string=False):
        """
        Handles the creation of a directory of recipes.

        This class, combined with YAML files describing test cases, can be used
        for building test cases of interdependent recipes in an isolated
        directory.

        Recipes are specified in a YAML file. Each top-level key represents
        a recipe, and the recipe will be written in a temp dir named after that
        key. Sub-keys are filenames to create in that directory, and the value
        of each sub-key is a string (likely a multi-line string indicated with
        a "|").

        For example, this YAML file::

            one:
              meta.yaml: |
                package:
                  name: one
                  version: 0.1
              build.sh: |
                  #!/bin/bash
                  # do installation
            two:
              meta.yaml: |
                package:
                  name: two
                  version: 0.1
              build.sh:
                  #!/bin/bash
                  python setup.py install

        will result in these files::

            /tmp/tmpdirname/
              one/
                meta.yaml
                build.sh
              two/
                meta.yaml
                build.sh

        Parameters
        ----------

        data : str
            If `from_string` is False, this is a filename relative to this
            module's file. If `from_string` is True, then use the contents of
            the string directly.

        from_string : bool


        Useful attributes:

        * recipes: a dict mapping recipe names to parsed meta.yaml contents
        * basedir: the tempdir containing all recipes. Many bioconda-utils
                   functions need the "recipes dir"; that's this basedir.
        * recipe_dirs: a dict mapping recipe names to newly-created recipe
                   dirs. These are full paths to subdirs in `basedir`.
        """

        if from_string:
            self.data = dedent(data)
            self.recipes = yaml.load(data)
        else:
            self.data = os.path.join(os.path.dirname(__file__), data)
            self.recipes = yaml.load(open(self.data))

    def write_recipes(self):
        basedir = tempfile.mkdtemp()
        self.recipe_dirs = {}
        for name, recipe in self.recipes.items():
            rdir = os.path.join(basedir, name)
            os.makedirs(rdir)
            self.recipe_dirs[name] = rdir
            for key, value in recipe.items():
                with open(os.path.join(rdir, key), 'w') as fout:
                    fout.write(value)
        self.basedir = basedir
