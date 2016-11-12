import os
from textwrap import dedent
import subprocess as sp

import pytest

from helpers import Recipes, ensure_missing, tmp_env_matrix
from bioconda_utils import pkg_test
from bioconda_utils import utils
from bioconda_utils import build

# TODO:
# need tests for channel order and extra channels (see
# https://github.com/bioconda/bioconda-utils/issues/31)
#

def _build_pkg():
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
    built_package = utils.built_package_path(recipe)
    ensure_missing(built_package)
    build.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        env=env_matrix)
    return built_package


def test_pkg_test():
    """
    Running a mulled-build test shouldn't cause any errors
    """
    built_package = _build_pkg()
    res = pkg_test.test_package(built_package)


def test_pkg_test_mulled_build_error():
    """
    Make sure calling mulled-build with the wrong arg fails correctly
    """
    built_package = _build_pkg()
    with pytest.raises(sp.CalledProcessError):
        res = pkg_test.test_package(built_package, mulled_args='--wrong-arg')
