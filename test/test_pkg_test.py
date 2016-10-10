import os
from textwrap import dedent
import subprocess as sp

import pytest

from helpers import Recipes, ensure_missing, built_package_path, tmp_env_matrix
from bioconda_utils import pkg_test
from bioconda_utils import utils


def test_pkg_test():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            test:
              commands:
                - "ls -la"
        """), from_string=True)
    r.write_recipes()
    env_matrix = list(utils.EnvMatrix(tmp_env_matrix()))[0]
    recipe = r.recipe_dirs['one']
    built_package = built_package_path(recipe)
    ensure_missing(built_package)
    utils.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        env=env_matrix)
    res = pkg_test.test_package(built_package)

def test_pkg_test_missing_involucro():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            test:
              commands:
                - "ls -la"
        """), from_string=True)
    r.write_recipes()
    env_matrix = list(utils.EnvMatrix(tmp_env_matrix()))[0]
    recipe = r.recipe_dirs['one']
    built_package = built_package_path(recipe)
    ensure_missing(built_package)
    utils.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        env=env_matrix)
    with pytest.raises(sp.CalledProcessError):
        res = pkg_test.test_package(built_package, mulled_args='--wrong-arg')
