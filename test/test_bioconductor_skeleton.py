import os
from textwrap import dedent
import subprocess as sp
import logging

import pytest

from bioconda_utils import bioconductor_skeleton
from bioconda_utils import cran_skeleton
from bioconda_utils import utils

import helpers

utils.setup_logger('bioconda_utils', 'debug')


def test_cran_write_recipe(tmpdir):
    cran_skeleton.write_recipe('locfit', recipe_dir=str(tmpdir), recursive=True)
    assert tmpdir.join('r-locfit', 'meta.yaml').exists()

def test_bioc_write_recipe_skip_in_condaforge(tmpdir):
    env_matrix = helpers.tmp_env_matrix()
    config = {
        'env_matrix': env_matrix,
        'channels': ['bioconda', 'conda-forge', 'defaults']
    }
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=True)

    for pkg in ['bioconductor-edger', 'bioconductor-limma', 'r-rcpp', 'r-lattice', 'r-locfit']:
        assert tmpdir.join(pkg).exists()


