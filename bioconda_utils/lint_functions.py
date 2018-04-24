from functools import partial
import glob
import os
import re

import pandas
import numpy as np

from .utils import get_meta_value


def _get_not_none(meta, key, none_subst=dict):
    """
    Return meta[key] if key is in meta and its value is not None, otherwise
    return none_subst().

    Some recipes have an empty build section, so it'll be None and we can't
    do a chained get.
    """
    ret = meta.get(key)
    return ret if (ret is not None) else none_subst()


def _subset_df(recipe, meta, df):
    """
    Helper function to get the subset of `df` for this recipe.
    """
    if df is None:
        # TODO: this is just a mockup; is there a better way to get the set of
        # expected columns from a channel dump?
        return pandas.DataFrame(
            np.nan, index=[],
            columns=['channel', 'name', 'version', 'build_number'])

    name = meta['package']['name']
    version = meta['package']['version']

    return df[
        (df.name == name) &
        (df.version == version)
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


def _has_preprocessing_selector(recipe):
    """
    Does the package have any preprocessing selectors?

    # [osx], # [not py27], etc.
    """
    # regex from
    # https://github.com/conda/conda-build/blob/cce72a95c61b10abc908ab1acf1e07854a236a75/conda_build/metadata.py#L107
    sel_pat = re.compile(r'(.+?)\s*(#.*)?\[([^\[\]]+)\](?(2).*)$')
    for line in open(os.path.join(recipe, 'meta.yaml')):
        line = line.rstrip()
        if line.startswith('#'):
            continue
        if sel_pat.match(line):
            return True


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
    build_section = _get_not_none(meta, 'build')
    build_number = int(build_section.get('number', 0))
    build_results = results[results.build_number == build_number]
    channels = set(build_results.channel)
    if 'bioconda' in channels:
        return {
            'already_in_bioconda': True,
            'fix': 'bump version or build number'
        }


def missing_home(recipe, meta, df):
    if not get_meta_value(meta, 'about', 'home'):
        return {
            'missing_home': True,
            'fix': 'add about:home',
        }


def missing_summary(recipe, meta, df):
    if not get_meta_value(meta, 'about', 'summary'):
        return {
            'missing_summary': True,
            'fix': 'add about:summary',
        }


def missing_license(recipe, meta, df):
    if not get_meta_value(meta, 'about', 'license'):
        return {
            'missing_license': True,
            'fix': 'add about:license'
        }


def missing_tests(recipe, meta, df):
    test_files = ['run_test.py', 'run_test.sh', 'run_test.pl']
    if not get_meta_value(meta, 'test'):
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

    if not any(map(partial(get_meta_value, src),
        (
            'md5',
            'sha1',
            'sha256',
        )
    )):
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
            'fix': ('setuptools might not be a run requirement (unless it uses '
                    'pkg_resources or setuptools console scripts)'),
        }


def has_windows_bat_file(recipe, meta, df):
    if len(glob.glob(os.path.join(recipe, '*.bat'))) > 0:
        return {
            'bat_file': True,
            'fix': 'remove windows .bat files'
        }


def should_be_noarch(recipe, meta, df):
    deps = _get_deps(meta)
    if (
        ('gcc' not in deps) and
        ('python' in deps) and
        # This will also exclude recipes with skip sections
        # which is a good thing, because noarch also implies independence of
        # the python version.
        not _has_preprocessing_selector(recipe)
    ) and (
        'noarch' not in _get_not_none(meta, 'build')
    ):
        return {
            'should_be_noarch': True,
            'fix': 'add "build: noarch" section',
        }


def should_not_be_noarch(recipe, meta, df):
    deps = _get_deps(meta)
    if (
        ('gcc' in deps) or
        _get_not_none(meta, 'build').get('skip', False)
    ) and (
        'noarch' in _get_not_none(meta, 'build')
    ):
        return {
            'should_not_be_noarch': True,
            'fix': 'remove "build: noarch" section',
        }


def setup_py_install_args(recipe, meta, df):
    if 'setuptools' not in _get_deps(meta, 'build'):
        return

    err = {
        'needs_setuptools_args': True,
        'fix': ('add "--single-version-externally-managed --record=record.txt" '
                'to setup.py command'),
    }

    script_line = _get_not_none(meta, 'build').get('script', '')
    if (
        'setup.py install' in script_line and
        '--single-version-externally-managed' not in script_line
    ):
        return err

    build_sh = os.path.join(recipe, 'build.sh')
    if not os.path.exists(build_sh):
        return

    contents = open(build_sh).read()
    if (
        'setup.py install' in contents and
        '--single-version-externally-managed' not in contents
    ):
        return err


def invalid_identifiers(recipe, meta, df):
    try:
        identifiers = meta['extra']['identifiers']
        if not isinstance(identifiers, list):
            return { 'invalid_identifiers': True,
                     'fix': 'extra:identifiers must hold a list of identifiers' }
        if not all(isinstance(i, str) for i in identifiers):
            return { 'invalid_identifiers': True,
                     'fix': 'each identifier must be a string' }
        if not all((':' in i) for i in identifiers):
            return { 'invalid_identifiers': True,
                     'fix': 'each identifier must be of the form '
                            'type:identifier (e.g., doi:123)' }
    except KeyError:
        # no identifier section
        return


def _pin(env_var, dep_name):
    """
    Generates a linting function that checks to make sure `dep_name` is pinned
    to `env_var` using jinja templating.
    """
    pin_pattern = re.compile(r"\{{\{{\s*{}\s*\}}\}}\*".format(env_var))
    def pin(recipe, meta, df):
        # Note that we can't parse the meta.yaml using a normal YAML parser if it
        # has jinja templating
        in_requirements = False
        section = None
        not_pinned = set()
        pinned = set()
        for line in open(os.path.join(recipe, 'meta.yaml')):
            line = line.rstrip("\n")
            if line.startswith("requirements:"):
                in_requirements = True
            elif line and not line.startswith(" ") and not line.startswith("#"):
                in_requirements = False
                section = None
            if in_requirements:
                dedented_line = line.lstrip(' ')
                if dedented_line.startswith("run:"):
                    section = "run"
                elif dedented_line.startswith("build:"):
                    section = "build"
                elif dedented_line.startswith('- {}'.format(dep_name)):
                    if pin_pattern.search(dedented_line) is None:
                        not_pinned.add(section)
                    else:
                        pinned.add(section)

        # two error cases: 1) run is not pinned but in build
        #                  2) build is not pinned and run is pinned
        # Everything else is ok. E.g., if dependency is not in run, we don't
        # need to pin build, because it is statically linked.
        if (("run" in not_pinned and "build" in pinned.union(not_pinned)) or
           ("run" in pinned and "build" in not_pinned)):
            err = {
                '{}_not_pinned'.format(dep_name): True,
                'fix': (
                    'pin {0} using jinja templating: '
                    '{{{{ {1} }}}}*'.format(dep_name, env_var))
            }
            return err

    pin.__name__ = "{}_not_pinned".format(dep_name)
    return pin


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
    # removing setuptools from run requirements should be done cautiously:
    # it breaks packages that use pkg_resources or setuptools console scripts!
    # uses_setuptools,
    has_windows_bat_file,

    # should_be_noarch,
    #
    should_not_be_noarch,
    setup_py_install_args,
    invalid_identifiers,
    _pin('CONDA_ZLIB', 'zlib'),
    _pin('CONDA_GMP', 'gmp'),
    _pin('CONDA_BOOST', 'boost'),
    _pin('CONDA_GSL', 'gsl'),
    _pin('CONDA_HDF5', 'hdf5'),
    _pin('CONDA_NCURSES', 'ncurses'),
    _pin('CONDA_HTSLIB', 'htslib'),
    _pin('CONDA_BZIP2', 'bzip2'),
)
