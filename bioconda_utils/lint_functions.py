import os
import glob


def _subset_df(recipe, meta, df):
    """
    Helper function to get the subset of `df` for this recipe.
    """
    name = meta['package']['name']
    version = meta['package']['version']

    # Some recipes have an empty build section, so it'll be None and we can't
    # do a chained get.
    build_number = 0
    build_section = meta.get('build')
    if build_section:
        build_number = int(build_section.get('number', 0))
    return df[
        (df.name == name) &
        (df.version == version) &
        (df.build_number == build_number)
    ]


def _get_deps(meta, section=None):
    """
    meta : dict-like
        Parsed meta.yaml file.

    section : str, list, or None
        If None, returns all dependencies. Otherwise can be a string or list of
        options [build, run, test] to return section-specific dependencies.
    """

    get_name = lambda dep: dep.split()[0]

    reqs = meta.get('requirements')
    if reqs is None:
        return []
    if section is None:
        sections = ['build', 'run', 'test']
    if isinstance(section, str):
        sections = [section]
    deps = []
    for s in sections:
        dep = reqs.get(s, [])
        if dep:
            deps += [get_name(d) for d in dep]
    return deps


def in_other_channels(recipe, meta, df):
    """
    Does the package exist in any other non-bioconda channels?
    """
    results = _subset_df(recipe, meta, df)
    channels = set(results.channel).difference(['bioconda'])
    if len(channels):
        return {
            'exists_in_channels': channels,
            'fix': 'consider deprecating',
        }


def already_in_bioconda(recipe, meta, df):
    """
    Does the package exist in bioconda?
    """
    results = _subset_df(recipe, meta, df)
    channels = set(results.channel)
    if 'bioconda' in channels:
        return {
            'already_in_bioconda': True,
            'fix': 'bump version or build number'
        }


def missing_home(recipe, meta, df):
    try:
        meta['about']['home']
    except KeyError:
        return {
            'missing_home': True,
            'fix': 'add about:home',
        }


def missing_summary(recipe, meta, df):
    try:
        meta['about']['summary']
    except KeyError:
        return {
            'missing_summary': True,
            'fix': 'add about:summary',
        }


def missing_license(recipe, meta, df):
    try:
        meta['about']['license']
    except KeyError:
        return {
            'missing_license': True,
            'fix': 'add about:license'
        }


def missing_tests(recipe, meta, df):
    test_files = ['run_test.py', 'run_test.sh', 'run_test.pl']
    if 'test' not in meta:
        if not any([os.path.exists(os.path.join(recipe, f)) for f in
                    test_files]):
            return {
                'no_tests': True,
                'fix': 'add basic tests',
            }


def missing_hash(recipe, meta, df):
    # could be a meta-package if no source section or if None
    try:
        src = meta['source']
        if src is None:
            return
    except KeyError:
        return

    if not any(
        (
            'md5' in src,
            'sha1' in src,
            'sha256' in src
        )
    ):
        return {
            'missing_hash': True,
            'fix': 'add md5, sha1, or sha256 hash to "source" section',
        }


def uses_git_url(recipe, meta, df):
    try:
        src = meta.get('source', {})
        if src is None:
            # metapackage?
            return

        if 'git_url' in src:
            return {
                'uses_git_url': True,
                'fix': 'use tarballs whenever possible',
            }
    except KeyError:
        return


def uses_perl_threaded(recipe, meta, df):
    if 'perl-threaded' in _get_deps(meta):
        return {
            'depends_on_perl_threaded': True,
            'fix': 'use "perl" instead of "perl-threaded"',
        }


def uses_javajdk(recipe, meta, df):
    if 'java-jdk' in _get_deps(meta):
        return {
            'depends_on_java-jdk': True,
            'fix': 'use "openjdk" instead of "java-jdk"',
        }


def uses_setuptools(recipe, meta, df):
    if 'setuptools' in _get_deps(meta, 'run'):
        return {
            'depends_on_setuptools': True,
            'fix': 'setuptools may not be required',
        }


def has_windows_bat_file(recipe, meta, df):
    if len(glob.glob(os.path.join(recipe, '*.bat'))) > 0:
        return {
            'bat_file': True,
            'fix': 'remove windows .bat files'
        }

registry = (
    in_other_channels,

    # disabling for now until we get better per-OS version detection
    # already_in_bioconda,
    missing_tests,
    missing_home,
    missing_license,
    missing_summary,
    missing_hash,
    uses_git_url,
    uses_javajdk,
    uses_perl_threaded,
    uses_setuptools,
    has_windows_bat_file,
)
