import sys

import pytest

from bioconda_utils import bioconductor_skeleton
from bioconda_utils import cran_skeleton
from bioconda_utils import utils

import helpers

env_matrix = helpers.tmp_env_matrix()
config = {
    'env_matrix': env_matrix,
    'channels': ['bioconda', 'conda-forge', 'defaults']
}


def test_cran_write_recipe(tmpdir):
    cran_skeleton.write_recipe('locfit', recipe_dir=str(tmpdir), recursive=False)
    assert tmpdir.join('r-locfit', 'meta.yaml').exists()


def test_bioc_write_recipe_skip_in_condaforge(tmpdir):
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=True,
        skip_if_in_channels=['conda-forge'])

    for pkg in [
        'bioconductor-edger', 'bioconductor-limma',
    ]:
        assert tmpdir.join(pkg).exists()

    for pkg in ['r-cpp', 'r-lattice', 'r-locfit']:
        assert not tmpdir.join(pkg).exists()


def test_bioc_write_recipe_no_skipping(tmpdir):
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=True,
        skip_if_in_channels=None)

    for pkg in [
        'bioconductor-edger', 'bioconductor-limma', 'r-rcpp'
        # sometime locfit and lattice don't build correctly, but we should
        # eventually ensure they are here as well.
        # 'r-locfit',
        # 'r-lattice',
    ]:
        assert tmpdir.join(pkg).exists()


def test_meta_contents(tmpdir):
    env_matrix = helpers.tmp_env_matrix()
    config = {
        'env_matrix': env_matrix,
        'channels': ['bioconda', 'conda-forge', 'defaults']
    }
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=False)

    edger_meta = utils.load_meta(str(tmpdir.join('bioconductor-edger')), {})
    assert 'r-rcpp' in edger_meta['requirements']['build']

    # note that the preprocessing selector is stripped off by yaml parsing, so
    # just check for gcc
    if sys.platform == 'linux':
        assert 'gcc' in edger_meta['requirements']['build']
    elif sys.platform == 'darwin':
        assert 'llvm' in edger_meta['requirements']['build']
    else:
        raise ValueError('Unhandled platform: {}'.format(sys.platform))


    # bioconductor, bioarchive, and cargoport
    assert len(edger_meta['source']['url']) == 3


def test_find_best_bioc_version():

    assert bioconductor_skeleton.find_best_bioc_version('DESeq2', '1.14.1') == '3.4'

    # Non-existent version:
    with pytest.raises(bioconductor_skeleton.PackageNotFoundError):
        bioconductor_skeleton.find_best_bioc_version('DESeq2', '5000')

    # Version existed at some point in the past, but only exists now on
    # bioaRchive:
    with pytest.raises(bioconductor_skeleton.PackageNotFoundError):
        bioconductor_skeleton.BioCProjectPage('BioBase', pkg_version='2.37.2')


def test_pkg_version():

    # version specified, but not bioc version
    b = bioconductor_skeleton.BioCProjectPage('DESeq2', pkg_version='1.14.1')
    assert b.version == '1.14.1'
    assert b.bioc_version == '3.4'
    assert b.bioconductor_tarball_url == 'http://bioconductor.org/packages/3.4/bioc/src/contrib/DESeq2_1.14.1.tar.gz'
    assert b.bioarchive_url is None
    assert b.cargoport_url == 'https://depot.galaxyproject.org/software/bioconductor-deseq2/bioconductor-deseq2_1.14.1_src_all.tar.gz'

    # bioc version specified, but not package version
    b = bioconductor_skeleton.BioCProjectPage('edgeR', bioc_version='3.5')
    assert b.version == '3.18.1'
    assert b.bioc_version == '3.5'
    assert b.bioconductor_tarball_url == 'http://bioconductor.org/packages/3.5/bioc/src/contrib/edgeR_3.18.1.tar.gz'
    assert b.bioarchive_url is None
    assert b.cargoport_url == 'https://depot.galaxyproject.org/software/bioconductor-edger/bioconductor-edger_3.18.1_src_all.tar.gz'


def test_bioarchive_exists_but_not_bioconductor():
    """
    BioCProjectPage init tries to find the package on the bioconductor site.
    Sometimes bioaRchive has cached the tarball but it no longer exists on the
    bioconductor site. In those cases, we're raising a PackageNotFoundError.
    """
    with pytest.raises(bioconductor_skeleton.PackageNotFoundError):
        b = bioconductor_skeleton.BioCProjectPage('BioBase', pkg_version='2.37.2')


def test_annotation_data(tmpdir):
    bioconductor_skeleton.write_recipe('AHCytoBands', str(tmpdir), config, recursive=True)

    meta = utils.load_meta(str(tmpdir.join('bioconductor-ahcytobands')), {})
    assert 'wget' in meta['requirements']['run']
    assert len(meta['source']['url']) == 3

    assert not tmpdir.join('bioconductor-ahcytobands', 'build.sh').exists()
    assert tmpdir.join('bioconductor-ahcytobands', 'post-link.sh').exists()
    assert tmpdir.join('bioconductor-ahcytobands', 'pre-unlink.sh').exists()
