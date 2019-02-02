from functools import partial
import glob
import os
import re

from . import utils


def _get_deps(meta, section=None):
    """
    meta : dict-like
        Parsed meta.yaml file.

    section : str, list, or None
        If None, returns all dependencies. Otherwise can be a string or list of
        options [build, host, run, test] to return section-specific dependencies.
    """
    def get_name(dep):
        return dep.split()[0]

    reqs = (meta.get_section('requirements') or {})
    if reqs is None:
        return []
    if section is None:
        sections = ['build', 'host', 'run', 'test']
    elif isinstance(section, str):
        sections = [section]
    else:
        sections = section
    deps = []
    for s in sections:
        dep = (reqs.get(s) or [])
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


def _has_compilers(meta):
    build_deps = _get_deps(meta, ('build', 'host'))
    return any(
        dep in {'gcc', 'llvm', 'clangdev', 'llvmdev'} or
        dep.startswith(('clang_', 'clangxx_', 'gcc_', 'gxx_', 'gfortran_', 'toolchain_'))
        for dep in build_deps
    )


def lint_multiple_metas(lint_function):
    def lint_metas(recipe, metas, *args, **kwargs):
        lint = partial(lint_function, recipe)
        for meta in metas:
            ret = lint(meta, *args, **kwargs)
            if ret is not None:
                ret['output'] = meta.name()
                return ret
    lint_metas.__name__ = lint_function.__name__
    return lint_metas


@lint_multiple_metas
def in_other_channels(recipe, meta):
    """
    Does the package exist in any other non-bioconda channels?
    """
    channels = set(utils.RepoData().get_package_data(
        key="channel",
        name=meta.get_value("package/name"),
        version=meta.get_value("package/version")
    ))
    channels.discard('bioconda')
    if channels:
        return {
            'exists_in_channels': channels,
            'fix': 'consider deprecating',
        }


@lint_multiple_metas
def already_in_bioconda(recipe, meta):
    """
    Does the package exist in bioconda?
    """
    channels = utils.RepoData().get_package_data(
        key="channel",
        name=meta.get_value("package/name"),
        version=meta.get_value("package/version"),
        build_number=meta.get_value("build/number", 0)
    )

    if 'bioconda' in channels:
        return {
            'already_in_bioconda': True,
            'fix': 'bump version or build number'
        }


@lint_multiple_metas
def missing_home(recipe, meta):
    if not meta.get_value('about/home'):
        return {
            'missing_home': True,
            'fix': 'add about:home',
        }


@lint_multiple_metas
def missing_summary(recipe, meta):
    if not meta.get_value('about/summary'):
        return {
            'missing_summary': True,
            'fix': 'add about:summary',
        }


@lint_multiple_metas
def missing_license(recipe, meta):
    if not meta.get_value('about/license'):
        return {
            'missing_license': True,
            'fix': 'add about:license'
        }


@lint_multiple_metas
def missing_tests(recipe, meta):
    test_files = ['run_test.py', 'run_test.sh', 'run_test.pl']
    if not meta.get_section('test'):
        if not any([os.path.exists(os.path.join(recipe, f)) for f in
                    test_files]):
            return {
                'no_tests': True,
                'fix': 'add basic tests',
            }


@lint_multiple_metas
def missing_hash(recipe, meta):
    # could be a meta-package if no source section or if None
    sources = meta.get_section('source')
    if not sources:
        return
    if isinstance(sources, dict):
        sources = [sources]

    for source in sources:
        if not any(source.get(checksum)
                   for checksum in ('md5', 'sha1', 'sha256')):
            return {
                'missing_hash': True,
                'fix': 'add md5, sha1, or sha256 hash to "source" section',
            }


@lint_multiple_metas
def uses_git_url(recipe, meta):
    sources = meta.get_section('source')
    if not sources:
        # metapackage?
        return
    if isinstance(sources, dict):
        sources = [sources]

    for source in sources:
        if 'git_url' in source:
            return {
                'uses_git_url': True,
                'fix': 'use tarballs whenever possible',
            }


@lint_multiple_metas
def uses_perl_threaded(recipe, meta):
    if 'perl-threaded' in _get_deps(meta):
        return {
            'depends_on_perl_threaded': True,
            'fix': 'use "perl" instead of "perl-threaded"',
        }


@lint_multiple_metas
def uses_javajdk(recipe, meta):
    if 'java-jdk' in _get_deps(meta):
        return {
            'depends_on_java-jdk': True,
            'fix': 'use "openjdk" instead of "java-jdk"',
        }


@lint_multiple_metas
def uses_setuptools(recipe, meta):
    if 'setuptools' in _get_deps(meta, 'run'):
        return {
            'depends_on_setuptools': True,
            'fix': ('setuptools might not be a run requirement (unless it uses '
                    'pkg_resources or setuptools console scripts)'),
        }


def has_windows_bat_file(recipe, metas):
    if len(glob.glob(os.path.join(recipe, '*.bat'))) > 0:
        return {
            'bat_file': True,
            'fix': 'remove windows .bat files'
        }


@lint_multiple_metas
def should_be_noarch(recipe, meta):
    deps = _get_deps(meta)
    if (
        (not _has_compilers(meta)) and
        ('python' in deps) and
        # This will also exclude recipes with skip sections
        # which is a good thing, because noarch also implies independence of
        # the python version.
        not _has_preprocessing_selector(recipe)
    ) and (
        'noarch' not in (meta.get_section('build') or {})
    ):
        return {
            'should_be_noarch': True,
            'fix': 'add "build: noarch" section',
        }


@lint_multiple_metas
def should_not_be_noarch(recipe, meta):
    if (
        _has_compilers(meta) or
        meta.get_value('build/skip', False)
    ) and (
        'noarch' in (meta.get_section('build') or {})
    ) and (
        meta.get_value('build/noarch', False)
    ):
        print("error")
        return {
            'should_not_be_noarch': True,
            'fix': 'remove "build: noarch" section',
        }


@lint_multiple_metas
def setup_py_install_args(recipe, meta):
    if 'setuptools' not in _get_deps(meta, 'build'):
        return

    err = {
        'needs_setuptools_args': True,
        'fix': ('add "--single-version-externally-managed --record=record.txt" '
                'to setup.py command'),
    }

    script_line = meta.get_value('build/script', '')
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


@lint_multiple_metas
def invalid_identifiers(recipe, meta):
    try:
        identifiers = meta.get_value('extra/identifiers', [])
        if not isinstance(identifiers, list):
            return {'invalid_identifiers': True,
                    'fix': 'extra:identifiers must hold a list of identifiers'}
        if not all(isinstance(i, str) for i in identifiers):
            return {'invalid_identifiers': True,
                    'fix': 'each identifier must be a string'}
        if not all((':' in i) for i in identifiers):
            return {'invalid_identifiers': True,
                    'fix': 'each identifier must be of the form '
                           'type:identifier (e.g., doi:123)'}
    except KeyError:
        # no identifier section
        return


def deprecated_numpy_spec(recipe, metas):
    with open(os.path.join(recipe, "meta.yaml")) as recipe:
        if re.search("numpy( )+x\.x", recipe.read()):
            return {'deprecated_numpy_spec': True,
                    'fix': 'omit x.x as pinning of numpy is now '
                           'handled automatically'}


@lint_multiple_metas
def should_not_use_fn(recipe, meta):
    sources = meta.get_section('source')
    if not sources:
        return
    if isinstance(sources, dict):
        sources = [sources]

    for source in sources:
        if 'fn' in source:
            return {
                'should_not_use_fn': True,
                'fix': 'URL should specify path to file, which will be used as the filename'
            }


@lint_multiple_metas
def should_use_compilers(recipe, meta):
    deps = _get_deps(meta)
    if (
        ('gcc' in deps) or
        ('llvm' in deps) or
        ('libgfortran' in deps) or
        ('libgcc' in deps)

    ):
        return {
            'should_use_compilers': True,
            'fix': 'use {{ compiler("c") }} or other new-style compilers',
        }


@lint_multiple_metas
def compilers_must_be_in_build(recipe, meta):
    if (

        any(['gcc_impl_linux-64' in i for i in _get_deps(meta, 'run')]) or
        any(['gcc_impl_linux-64' in i for i in _get_deps(meta, 'host')]) or
        any(['clang_osx-64' in i for i in _get_deps(meta, 'run')]) or
        any(['clang_osx-64' in i for i in _get_deps(meta, 'host')]) or
        any(['toolchain' in i for i in _get_deps(meta, 'run')]) or
        any(['toolchain' in i for i in _get_deps(meta, 'host')])
    ):
        return {
            'compilers_must_be_in_build': True,
            'fix': (
                '{{ compiler("c") }} or other new-style compliers can '
                'only go in the build: section')
        }


#def bioconductor_37(recipe, meta):
#    for line in open(os.path.join(recipe, 'meta.yaml')):
#        if ('{% set bioc = "3.7" %}' in line) or ('{% set bioc = "release" %}' in line):
#            return {
#                'bioconductor_37': True,
#                'fix': 'Need to wait until R 3.5 conda package is available',
#            }


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
    should_be_noarch,
    should_not_be_noarch,
    setup_py_install_args,
    invalid_identifiers,
    deprecated_numpy_spec,
    should_not_use_fn,
    should_use_compilers,
    compilers_must_be_in_build,
    #bioconductor_37,
)
