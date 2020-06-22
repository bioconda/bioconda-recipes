import pytest

# TODO: Remove this once bioarchive is up again.
from datetime import datetime
from functools import partial
SKIP_DUE_TO_BIOARCHIVE_OUTAGE = partial(
    pytest.mark.skipif,
    datetime.now() < datetime(2020, 6, 22),
    reason='temporarily skipped due to bioarchive.galaxyproject.org outage',
)

from bioconda_utils import bioconductor_skeleton
from bioconda_utils import cran_skeleton
from bioconda_utils import utils


config = {
    'channels': ['conda-forge', 'bioconda', 'defaults']
}


def test_cran_write_recipe(tmpdir):
    cran_skeleton.write_recipe('locfit', recipe_dir=str(tmpdir), recursive=False)
    assert tmpdir.join('r-locfit', 'meta.yaml').exists()
    assert tmpdir.join('r-locfit', 'build.sh').exists()
    assert tmpdir.join('r-locfit', 'bld.bat').exists()


def test_cran_write_recipe_no_windows(tmpdir):
    cran_skeleton.write_recipe('locfit', recipe_dir=str(tmpdir), recursive=False, no_windows=True)
    assert tmpdir.join('r-locfit', 'meta.yaml').exists()
    assert tmpdir.join('r-locfit', 'build.sh').exists()
    assert not tmpdir.join('r-locfit', 'bld.bat').exists()
    for line in tmpdir.join('r-locfit', 'meta.yaml').readlines():
        if 'skip: True' in line:
            assert '[win]' in line


@pytest.fixture(scope="module")
def bioc_fetch():
    release = bioconductor_skeleton.latest_bioconductor_release_version()
    return bioconductor_skeleton.fetchPackages(release)


@pytest.mark.skip(reason="Does not work since new bioconductor release?")
def test_bioc_write_recipe_skip_in_condaforge(tmpdir, bioc_fetch):
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=True,
        packages=bioc_fetch,
        skip_if_in_channels=['conda-forge'])

    for pkg in [
        'bioconductor-edger', 'bioconductor-limma',
    ]:
        assert tmpdir.join(pkg).exists()

    for pkg in ['r-cpp', 'r-lattice', 'r-locfit']:
        assert not tmpdir.join(pkg).exists()


@pytest.mark.skip(reason="Does not work since new bioconductor release?")
def test_bioc_write_recipe_no_skipping(tmpdir, bioc_fetch):
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=True,
        packages=bioc_fetch,
        skip_if_in_channels=None)

    for pkg in [
        'bioconductor-edger', 'bioconductor-limma', 'r-rcpp'
        # sometime locfit and lattice don't build correctly, but we should
        # eventually ensure they are here as well.
        # 'r-locfit',
        # 'r-lattice',
    ]:
        assert tmpdir.join(pkg).exists()


@pytest.mark.skip(reason="Does not work since new bioconductor release?")
def test_meta_contents(tmpdir, bioc_fetch):
    config = {
        'channels': ['conda-forge', 'bioconda', 'defaults']
    }
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=False, packages=bioc_fetch)

    edger_meta = utils.load_first_metadata(str(tmpdir.join('bioconductor-edger'))).meta
    assert 'r-rcpp' in edger_meta['requirements']['run']

    # The rendered meta has {{ compiler('c') }} filled in, so we need to check
    # for one of those filled-in values.
    names = [i.split()[0] for i in edger_meta['requirements']['build']]
    assert 'libstdcxx-ng' in names or 'clang_osx-64' in names

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


@SKIP_DUE_TO_BIOARCHIVE_OUTAGE
def test_pkg_version():

    # version specified, but not bioc version
    b = bioconductor_skeleton.BioCProjectPage('DESeq2', pkg_version='1.14.1')
    assert b.version == '1.14.1'
    assert b.bioc_version == '3.4'
    assert b.bioconductor_tarball_url == (
        'https://bioconductor.org/packages/3.4/bioc/src/contrib/DESeq2_1.14.1.tar.gz')
    assert b.bioarchive_url is None
    assert b.cargoport_url == (
        'https://depot.galaxyproject.org/software/bioconductor-deseq2/bioconductor-deseq2_1.14.1_src_all.tar.gz')  # noqa: E501: line too long

    # bioc version specified, but not package version
    b = bioconductor_skeleton.BioCProjectPage('edgeR', bioc_version='3.5')
    assert b.version == '3.18.1'
    assert b.bioc_version == '3.5'
    assert b.bioconductor_tarball_url == (
        'https://bioconductor.org/packages/3.5/bioc/src/contrib/edgeR_3.18.1.tar.gz')
    assert b.bioarchive_url is None
    assert b.cargoport_url == (
        'https://depot.galaxyproject.org/software/bioconductor-edger/bioconductor-edger_3.18.1_src_all.tar.gz')  # noqa: E501: line too long


def test_bioarchive_exists_but_not_bioconductor():
    """
    BioCProjectPage init tries to find the package on the bioconductor site.
    Sometimes bioaRchive has cached the tarball but it no longer exists on the
    bioconductor site. In those cases, we're raising a PackageNotFoundError.

    It's possible to build a recipe based on a package only found in
    bioarchive, but I'm not sure we want to support that in an automated
    fashion. In those cases it would be best to build the recipe manually.
    """
    with pytest.raises(bioconductor_skeleton.PackageNotFoundError):
        bioconductor_skeleton.BioCProjectPage('BioBase', pkg_version='2.37.2')


@SKIP_DUE_TO_BIOARCHIVE_OUTAGE
def test_bioarchive_exists():
    # package found on both bioconductor and bioarchive.
    b = bioconductor_skeleton.BioCProjectPage('DESeq', pkg_version='1.26.0')
    assert b.bioarchive_url == 'https://bioarchive.galaxyproject.org/DESeq_1.26.0.tar.gz'


@SKIP_DUE_TO_BIOARCHIVE_OUTAGE
def test_annotation_data(tmpdir, bioc_fetch):
    bioconductor_skeleton.write_recipe('AHCytoBands', str(tmpdir), config, recursive=False, packages=bioc_fetch)
    meta = utils.load_first_metadata(str(tmpdir.join('bioconductor-ahcytobands'))).meta
    assert any(dep.startswith('curl ') for dep in meta['requirements']['run'])
    assert len(meta['source']['url']) == 3
    assert not tmpdir.join('bioconductor-ahcytobands', 'build.sh').exists()
    assert tmpdir.join('bioconductor-ahcytobands', 'post-link.sh').exists()
    assert tmpdir.join('bioconductor-ahcytobands', 'pre-unlink.sh').exists()


@SKIP_DUE_TO_BIOARCHIVE_OUTAGE
def test_experiment_data(tmpdir, bioc_fetch):
    bioconductor_skeleton.write_recipe('Affyhgu133A2Expr', str(tmpdir), config, recursive=False, packages=bioc_fetch)
    meta = utils.load_first_metadata(str(tmpdir.join('bioconductor-affyhgu133a2expr'))).meta
    assert any(dep.startswith('curl ') for dep in meta['requirements']['run'])
    assert len(meta['source']['url']) == 3
    assert not tmpdir.join('bioconductor-affyhgu133a2expr', 'build.sh').exists()
    assert tmpdir.join('bioconductor-affyhgu133a2expr', 'post-link.sh').exists()
    assert tmpdir.join('bioconductor-affyhgu133a2expr', 'pre-unlink.sh').exists()


def test_nonexistent_pkg(tmpdir, bioc_fetch):

    # no such package exists in the current bioconductor
    with pytest.raises(bioconductor_skeleton.PackageNotFoundError):
        bioconductor_skeleton.write_recipe(
            'nonexistent', str(tmpdir), config, recursive=True, packages=bioc_fetch)

    # package exists, but not this version
    with pytest.raises(bioconductor_skeleton.PackageNotFoundError):
        bioconductor_skeleton.write_recipe(
            'DESeq', str(tmpdir), config, recursive=True, pkg_version='5000', packages=bioc_fetch)


@pytest.mark.skip(reason="Does not work since new bioconductor release?")
def test_overwrite(tmpdir, bioc_fetch):
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=False, packages=bioc_fetch)

    # Same thing with force=False returns ValueError
    with pytest.raises(ValueError):
        bioconductor_skeleton.write_recipe(
            'edgeR', recipe_dir=str(tmpdir), config=config, recursive=False, packages=bioc_fetch)

    # But same thing with force=True is OK
    bioconductor_skeleton.write_recipe(
        'edgeR', recipe_dir=str(tmpdir), config=config, recursive=False, force=True, packages=bioc_fetch)
