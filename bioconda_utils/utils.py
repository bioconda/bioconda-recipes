#!/usr/bin/env python

import os
import re
import glob
import fnmatch
import subprocess as sp
import sys
import shutil
import contextlib
from collections import Counter, Iterable, defaultdict, namedtuple
from itertools import product, chain, groupby
import logging
import datetime
from threading import Event, Thread
from pathlib import PurePath

from conda_build import api
from conda.exports import VersionOrder
import pkg_resources
import networkx as nx
import requests
from jsonschema import validate
from distutils.version import LooseVersion
import yaml
import jinja2
from jinja2 import Environment, PackageLoader
from colorlog import ColoredFormatter
import tqdm


class TqdmHandler(logging.StreamHandler):
    """Tqdm aware logging StreamHandler

    Passes all log writes through tqdm to allow progress bars
    and log messages to coexist without clobbering terminal
    """
    def emit(self, record):
        tqdm.tqdm.write(self.format(record))


log_stream_handler = TqdmHandler()
log_stream_handler.setFormatter(ColoredFormatter(
        "%(asctime)s %(log_color)sBIOCONDA %(levelname)s%(reset)s %(message)s",
        datefmt="%H:%M:%S",
        reset=True,
        log_colors={
            'DEBUG': 'cyan',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red',
        }))


def setup_logger(name, loglevel=None):
    logger = logging.getLogger(name)
    logger.propagate = False
    if loglevel:
        logger.setLevel(getattr(logging, loglevel.upper()))
    logger.addHandler(log_stream_handler)
    return logger


logger = setup_logger(__name__)


class JinjaSilentUndefined(jinja2.Undefined):
    def _fail_with_undefined_error(self, *args, **kwargs):
        return ""

    __add__ = __radd__ = __mul__ = __rmul__ = __div__ = __rdiv__ = \
        __truediv__ = __rtruediv__ = __floordiv__ = __rfloordiv__ = \
        __mod__ = __rmod__ = __pos__ = __neg__ = __call__ = \
        __getitem__ = __lt__ = __le__ = __gt__ = __ge__ = __int__ = \
        __float__ = __complex__ = __pow__ = __rpow__ = \
        _fail_with_undefined_error


jinja = Environment(
    loader=PackageLoader('bioconda_utils', 'templates'),
    trim_blocks=True,
    lstrip_blocks=True
)


jinja_silent_undef = Environment(
    undefined=JinjaSilentUndefined
)


# Patterns of allowed environment variables that are allowed to be passed to
# conda-build.
ENV_VAR_WHITELIST = [
    'CONDA_*',
    'PATH',
    'LC_*',
    'LANG',
    'MACOSX_DEPLOYMENT_TARGET'
]

# Of those that make it through the whitelist, remove these specific ones
ENV_VAR_BLACKLIST = [
    'CONDA_PREFIX',
]

# Of those, also remove these when we're running in a docker container
ENV_VAR_DOCKER_BLACKLIST = [
    'PATH',
]


def get_free_space():
    """Return free space in MB on disk"""
    s = os.statvfs(os.getcwd())
    return s.f_frsize * s.f_bavail / (1024 ** 2)


def allowed_env_var(s, docker=False):
    for pattern in ENV_VAR_WHITELIST:
        if fnmatch.fnmatch(s, pattern):
            for bpattern in ENV_VAR_BLACKLIST:
                if fnmatch.fnmatch(s, bpattern):
                    return False
            if docker:
                for dpattern in ENV_VAR_DOCKER_BLACKLIST:
                    if fnmatch.fnmatch(s, dpattern):
                        return False
            return True


def bin_for(name='conda'):
    if 'CONDA_ROOT' in os.environ:
        return os.path.join(os.environ['CONDA_ROOT'], 'bin', name)
    return name


@contextlib.contextmanager
def temp_env(env):
    """
    Context manager to temporarily set os.environ.

    Used to send values in `env` to processes that only read the os.environ,
    for example when filling in meta.yaml with jinja2 template variables.

    All values are converted to string before sending to os.environ
    """
    env = dict(env)
    orig = os.environ.copy()
    _env = {k: str(v) for k, v in env.items()}
    os.environ.update(_env)
    try:
        yield
    finally:
        os.environ.clear()
        os.environ.update(orig)


@contextlib.contextmanager
def sandboxed_env(env):
    """
    Context manager to temporarily set os.environ, only allowing env vars from
    the existing `os.environ` or the provided `env` that match
    ENV_VAR_WHITELIST globs.
    """
    env = dict(env)
    orig = os.environ.copy()

    _env = {k: v for k, v in orig.items() if allowed_env_var(k)}
    _env.update({k: str(v) for k, v in env.items() if allowed_env_var(k)})

    os.environ = _env

    try:
        yield
    finally:
        os.environ.clear()
        os.environ.update(orig)


def load_all_meta(recipe, config=None, finalize=True):
    """
    For each environment, yield the rendered meta.yaml.

    Parameters
    ----------
    finalize : bool
        If True, do a full conda-build render. Determines exact package builds
        of build/host dependencies. It involves costly dependency resolution
        via conda and also download of those packages (to inspect possible
        run_exports). For fast-running tasks like linting, set to False.
    """
    if config is None:
        config = load_conda_build_config()
    # `bypass_env_check=True` prevents evaluating (=environment solving) the
    # package versions used for `pin_compatible` and the like.
    # To avoid adding a separate `bypass_env_check` alongside every `finalize`
    # parameter, just assume we always want to bypass if `finalize is True`.
    bypass_env_check = (not finalize)
    return [meta for (meta, _, _) in api.render(recipe,
                                                config=config,
                                                finalize=finalize,
                                                bypass_env_check=bypass_env_check,
                                                )]



def load_meta_fast(recipe, env=None):
    """
    Given a package name, find the current meta.yaml file, parse it, and return
    the dict.

    Parameters
    ----------
    recipe : str
        Path to recipe (directory containing the meta.yaml file)

    env: Optional[dict]
        Variables to expand
    """
    if not env:
        env = {}

    pth = os.path.join(recipe, 'meta.yaml')
    template = jinja_silent_undef.from_string(open(pth, 'r', encoding='utf-8').read())
    meta = yaml.load(template.render(env))
    return meta


def load_conda_build_config(platform=None, trim_skip=True):
    """
    Load conda build config while considering global pinnings from conda-forge.
    """
    config = api.Config(
        no_download_source=True,
        set_build_id=False)

    # get environment root
    env_root = PurePath(shutil.which("bioconda-utils")).parents[1]
    # set path to pinnings from conda forge package
    config.exclusive_config_file = os.path.join(env_root,
                                                "conda_build_config.yaml")
    config.variant_config_files = [
        os.path.join(
            os.path.dirname(__file__),
            'bioconda_utils-conda_build_config.yaml')
    ]
    for cfg in config.variant_config_files:
        assert os.path.exists(cfg), ('error: {0} does not exist'.format(cfg))
    assert os.path.exists(config.exclusive_config_file), (
        "error: conda_build_config.yaml not found in environment root")
    if platform:
        config.platform = platform
    config.trim_skip = trim_skip
    return config


CondaBuildConfigFile = namedtuple('CondaBuildConfigFile', (
    'arg',  # either '-e' or '-m'
    'path',
))


def get_conda_build_config_files(config=None):
    if config is None:
        config = load_conda_build_config()
    # TODO: open PR upstream for conda-build to support multiple exclusive_config_files
    for file_path in ([config.exclusive_config_file] if config.exclusive_config_file else []):
        yield CondaBuildConfigFile('-e', file_path)
    for file_path in (config.variant_config_files or []):
        yield CondaBuildConfigFile('-m', file_path)


def load_first_metadata(recipe, config=None, finalize=True):
    """
    Returns just the first of possibly many metadata files. Used for when you
    need to do things like check a package name or version number (which are
    not expected to change between variants).

    If the recipe will be skipped, then returns None

    Parameters
    ----------
    finalize : bool
        If True, do a full conda-build render. Determines exact package builds
        of build/host dependencies. It involves costly dependency resolution
        via conda and also download of those packages (to inspect possible
        run_exports). For fast-running tasks like linting, set to False.
    """
    metas = load_all_meta(recipe, config, finalize=finalize)
    if len(metas) > 0:
        return metas[0]


@contextlib.contextmanager
def temp_os(platform):
    """
    Context manager to temporarily set sys.platform.
    """
    original = sys.platform
    sys.platform = platform
    try:
        yield
    finally:
        sys.platform = original


def run(cmds, env=None, mask=None, **kwargs):
    """
    Wrapper around subprocess.run()

    Explicitly decodes stdout to avoid UnicodeDecodeErrors that can occur when
    using the `universal_newlines=True` argument in the standard
    subprocess.run.

    Also uses check=True and merges stderr with stdout. If a CalledProcessError
    is raised, the output is decoded.

    Returns the subprocess.CompletedProcess object.
    """
    try:
        p = sp.run(cmds, stdout=sp.PIPE, stderr=sp.STDOUT, check=True, env=env,
                   **kwargs)
        p.stdout = p.stdout.decode(errors='replace')
    except sp.CalledProcessError as e:
        e.stdout = e.stdout.decode(errors='replace')
        # mask command arguments

        def do_mask(arg):
            if mask is None:
                # caller has not considered masking, hide the entire command
                # for security reasons
                return '<hidden>'
            elif mask is False:
                # masking has been deactivated
                return arg
            for m in mask:
                arg = arg.replace(m, '<hidden>')
            return arg
        e.cmd = [do_mask(c) for c in e.cmd]
        logger.error('COMMAND FAILED: %s', ' '.join(e.cmd))
        logger.error('STDOUT+STDERR:\n%s', do_mask(e.stdout))
        raise e
    return p


def envstr(env):
    env = dict(env)
    return ';'.join(['='.join([i, str(j)]) for i, j in sorted(env.items())])


def flatten_dict(dict):
    for key, values in dict.items():
        if isinstance(values, str) or not isinstance(values, Iterable):
            values = [values]
        yield [(key, value) for value in values]


class EnvMatrix:
    """
    Intended to be initialized with a YAML file and iterated over to yield all
    combinations of environments.

    YAML file has the following format::

        CONDA_PY:
          - "2.7"
          - "3.5"
        CONDA_BOOST: "1.60"
        CONDA_PERL: "5.22.0"
        CONDA_NPY: "110"
        CONDA_NCURSES: "5.9"
        CONDA_GSL: "1.16"

    """

    def __init__(self, env):
        """
        Parameters
        ----------

        env : str or dict
            If str, assume it's a path to a YAML-format filename and load it
            into a dict. If a dict is provided, use it directly.
        """
        if isinstance(env, str):
            with open(env) as f:
                self.env = yaml.load(f)
        else:
            self.env = env
        for key, val in self.env.items():
            if key != "CONDA_PY" and not isinstance(val, str):
                raise ValueError(
                    "All versions except CONDA_PY must be strings.")

    def __iter__(self):
        """
        Given the YAML::

            CONDA_PY:
              - "2.7"
              - "3.5"
            CONDA_BOOST: "1.60"
            CONDA_NPY: "110"

        We get the following sets of env vars::

          [('CONDA_BOOST', '1.60'), ('CONDA_PY', '2.7'), ('CONDA_NPY', '110')]
          [('CONDA_BOOST', '1.60'), ('CONDA_PY', '3.5'), ('CONDA_NPY', '110')]

        A copy of the entire os.environ dict is updated and yielded for each of
        these sets.
        """
        for env in product(*flatten_dict(self.env)):
            yield env


def get_deps(recipe=None, meta=None, build=True):
    """
    Generator of dependencies for a single recipe

    Only names (not versions) of dependencies are yielded.

    If the variant/version matrix yields multiple instances of the metadata,
    the union of these dependencies is returned.

    Parameters
    ----------
    recipe : str or MetaData
        If string, it is a path to the recipe; otherwise assume it is a parsed
        conda_build.metadata.MetaData instance.

    build : bool
        If True yield build dependencies, if False yield run dependencies.
    """
    if recipe is not None:
        assert isinstance(recipe, str)
        metadata = load_all_meta(recipe, finalize=False)
    elif meta is not None:
        metadata = [meta]
    else:
        raise ValueError("Either meta or recipe has to be specified.")

    all_deps = set()
    for meta in metadata:
        if build:
            deps = meta.get_value('requirements/build', [])
        else:
            deps = meta.get_value('requirements/run', [])
        all_deps.update(dep.split()[0] for dep in deps)
    return all_deps


def get_dag(recipes, config, blacklist=None, restrict=True):
    """
    Returns the DAG of recipe paths and a dictionary that maps package names to
    lists of recipe paths to all defined versions of the package.  defined
    versions.

    Parameters
    ----------
    recipes : iterable
        An iterable of recipe paths, typically obtained via `get_recipes()`

    blacklist : set
        Package names to skip

    restrict : bool
        If True, then dependencies will be included in the DAG only if they are
        themselves in `recipes`. Otherwise, include all dependencies of
        `recipes`.

    Returns
    -------
    dag : nx.DiGraph
        Directed graph of packages -- nodes are package names; edges are
        dependencies (both run and build dependencies)

    name2recipe : dict
        Dictionary mapping package names to recipe paths. These recipe path
        values are lists and contain paths to all defined versions.
    """
    logger.info("Generating DAG")
    recipes = list(recipes)
    metadata = []
    for i, recipe in enumerate(sorted(recipes)):
        try:
            meta = load_meta_fast(recipe)
            metadata.append((meta, recipe))
            if i % 100 == 0:
                logger.info("Inspected {} of {} recipes".format(i, len(recipes)))
        except Exception:
            raise ValueError('Problem inspecting {0}'.format(recipe))
    if blacklist is None:
        blacklist = set()

    # name2recipe is meta.yaml's package:name mapped to the recipe path.
    #
    # A name should map to exactly one recipe. It is possible for multiple
    # names to map to the same recipe, if the package name somehow depends on
    # the environment.
    #
    # Note that this may change once we support conda-build 3.
    name2recipe = defaultdict(set)
    for meta, recipe in metadata:
        name = meta["package"]["name"]
        if name not in blacklist:
            name2recipe[name].update([recipe])

    def get_deps(meta, sec):
        reqs = meta.get("requirements")
        if not reqs:
            return []
        deps = reqs.get(sec)
        if not deps:
            return []
        return [dep.split()[0] for dep in deps if dep]


    def get_inner_deps(dependencies):
        dependencies = list(dependencies)
        for dep in dependencies:
            if dep in name2recipe or not restrict:
                yield dep

    dag = nx.DiGraph()
    dag.add_nodes_from(meta["package"]["name"]
                       for meta, recipe in metadata)
    for meta, recipe in metadata:
        name = meta["package"]["name"]
        dag.add_edges_from(
            (dep, name)
            for dep in set(chain(
                get_inner_deps(get_deps(meta, "build")),
                get_inner_deps(get_deps(meta, "host")),
                get_inner_deps(get_deps(meta, "run")),
            ))
        )

    return dag, name2recipe


def get_recipes(recipe_folder, package="*"):
    """
    Generator of recipes.

    Finds (possibly nested) directories containing a `meta.yaml` file.

    Parameters
    ----------
    recipe_folder : str
        Top-level dir of the recipes

    package : str or iterable
        Pattern or patterns to restrict the results.
    """
    if isinstance(package, str):
        package = [package]
    for p in package:
        logger.debug("get_recipes(%s, package='%s'): %s",
                     recipe_folder, package, p)
        path = os.path.join(recipe_folder, p)
        for new_dir in glob.glob(path):
            for dir_path, dir_names, file_names in os.walk(new_dir):
                if "meta.yaml" in file_names:
                    yield dir_path


def get_latest_recipes(recipe_folder, config, package="*"):
    """
    Generator of recipes.

    Finds (possibly nested) directories containing a `meta.yaml` file and returns
    the latest version of each recipe.

    Parameters
    ----------
    recipe_folder : str
        Top-level dir of the recipes

    config : dict or filename

    package : str or iterable
        Pattern or patterns to restrict the results.
    """

    def toplevel(x):
        return x.replace(
            recipe_folder, '').strip(os.path.sep).split(os.path.sep)[0]

    config = load_config(config)
    recipes = sorted(get_recipes(recipe_folder, package), key=toplevel)

    for package, group in groupby(recipes, key=toplevel):
        group = list(group)
        if len(group) == 1:
            yield group[0]
        else:
            def get_version(p):
                meta_path = os.path.join(p, 'meta.yaml')
                meta = load_first_metadata(meta_path, finalize=False)
                version = meta.get_value('package/version')
                return VersionOrder(version)
            sorted_versions = sorted(group, key=get_version)
            if sorted_versions:
                yield sorted_versions[-1]


def get_channel_repodata(channel='bioconda', platform=None):
    """
    Returns the parsed JSON repodata for a channel from conda.anaconda.org.

    A tuple of dicts is returned, (repodata, noarch_repodata). The first is the
    repodata for the provided platform, and the second is the noarch repodata,
    which will be the same for a channel no matter what the platform.

    Parameters
    ----------
    channel : str
        Channel to retrieve packages for

    platform : None | linux | osx
        Platform (OS) to retrieve packages for from `channel`. If None, use the
        currently-detected platform.
    """
    url_template = 'https://conda.anaconda.org/{channel}/{arch}/repodata.json'
    if (
        (platform == 'linux') or
        (platform is None and sys.platform.startswith("linux"))
    ):
        arch = 'linux-64'
    elif (
        (platform == 'osx') or
        (platform is None and sys.platform.startswith("darwin"))
    ):
        arch = 'osx-64'
    else:
        raise ValueError(
            'Unsupported OS: bioconda only supports linux and osx.')

    url = url_template.format(channel=channel, arch=arch)
    repodata = requests.get(url)
    if repodata.status_code != 200:
        raise requests.HTTPError(
            '{0.status_code} {0.reason} for {1}'
            .format(repodata, url))

    noarch_url = url_template.format(channel=channel, arch='noarch')
    noarch_repodata = requests.get(noarch_url)
    if noarch_repodata.status_code != 200:
        raise requests.HTTPError(
            '{0.status_code} {0.reason} for {1}'
            .format(noarch_repodata, noarch_url))
    return repodata.json(), noarch_repodata.json()


PackageKey = namedtuple('PackageKey', ('name', 'version', 'build_number'))
PackageBuild = namedtuple('PackageBuild', ('subdir', 'build_id'))


class DivergentBuildsError(Exception):
    pass


def get_channel_packages(channel='bioconda', platform=None):
    """
    Return a PackageKey -> set(PackageBuild) mapping.
    Retrieves the existing packages for a channel from conda.anaconda.org.

    Parameters
    ----------
    channel : str
        Channel to retrieve packages for

    platform : None | linux | osx
        Platform (OS) to retrieve packages for from `channel`. If None, use the
        currently-detected platform.
    """
    repodata, noarch_repodata = get_channel_repodata(
        channel=channel, platform=platform)
    channel_packages = defaultdict(set)
    for repo in (repodata, noarch_repodata):
        subdir = repo['info']['subdir']
        for package in repo['packages'].values():
            pkg_key = PackageKey(
                package['name'], package['version'], package['build_number'])
            pkg_build = PackageBuild(subdir, package['build'])
            channel_packages[pkg_key].add(pkg_build)
    channel_packages.default_factory = None
    return channel_packages


def _string_or_float_to_integer_python(s):
    """
    conda-build 2.0.4 expects CONDA_PY values to be integers (e.g., 27, 35) but
    older versions were OK with strings or even floats.

    To avoid editing existing config files, we support those values here.
    """

    try:
        s = float(s)
        if s < 10:  # it'll be a looong time before we hit Python 10.0
            s = int(s * 10)
        else:
            s = int(s)
    except ValueError:
        raise ValueError("{} is an unrecognized Python version".format(s))
    return s


def built_package_paths(recipe):
    """
    Returns the path to which a recipe would be built.

    Does not necessarily exist; equivalent to `conda build --output recipename`
    but without the subprocess.
    """
    config = load_conda_build_config()
    paths = api.get_output_file_paths(recipe, config=config)
    return paths


def last_commit_to_master():
    """
    Identifies the day of the last commit to master branch.
    """
    if not shutil.which('git'):
        raise ValueError("git not found")
    p = sp.run(
        'git log master --date=iso | grep "^Date:" | head -n1',
        shell=True, stdout=sp.PIPE, check=True
    )
    date = datetime.datetime.strptime(
        p.stdout[:-1].decode().split()[1],
        '%Y-%m-%d')
    return date


def file_from_commit(commit, filename):
    """
    Returns the contents of a file at a particular commit as a string.

    Parameters
    ----------
    commit : commit-like string

    filename : str
    """
    if commit == 'HEAD':
        return open(filename).read()

    p = run(['git', 'show', '{0}:{1}'.format(commit, filename)])
    return str(p.stdout)


def newly_unblacklisted(config_file, recipe_folder, git_range):
    """
    Returns the set of recipes that were blacklisted in master branch but have
    since been removed from the blacklist. Considers the contents of all
    blacklists in the current config file and all blacklists in the same config
    file in master branch.

    Parameters
    ----------

    config_file : str
        Needs filename (and not dict) because we check what the contents of the
        config file were in the master branch.

    recipe_folder : str
        Path to recipe dir, needed by get_blacklist

    git_range : str or list
        If str or single-item list. If 'HEAD' or ['HEAD'] or ['master',
        'HEAD'], compares the current changes to master. If other commits are
        specified, then use those commits directly via `git show`.
    """

    # 'HEAD' becomes ['HEAD'] and then ['master', 'HEAD'].
    # ['HEAD'] becomes ['master', 'HEAD']
    # ['HEAD~~', 'HEAD'] stays the same
    if isinstance(git_range, str):
        git_range = [git_range]

    if len(git_range) == 1:
        git_range = ['master', git_range[0]]

    # Get the set of previously blacklisted recipes by reading the original
    # config file and then all the original blacklists it had listed
    previous = set()
    orig_config = file_from_commit(git_range[0], config_file)
    for bl in yaml.load(orig_config)['blacklists']:
        with open('.tmp.blacklist', 'w', encoding='utf8') as fout:
            fout.write(file_from_commit(git_range[0], bl))
        previous.update(get_blacklist(['.tmp.blacklist'], recipe_folder))
        os.unlink('.tmp.blacklist')

    current = get_blacklist(
        yaml.load(
            file_from_commit(git_range[1], config_file))['blacklists'],
        recipe_folder)
    results = previous.difference(current)
    logger.info('Recipes newly unblacklisted:\n%s', '\n'.join(list(results)))
    return results


def changed_since_master(recipe_folder):
    """
    Return filenames changed since master branch.

    Note that this uses `origin`, so if you are working on a fork of the main
    repo and have added the main repo as `upstream`, then you'll have to do
    a `git checkout master && git pull upstream master` to update your fork.
    """
    p = run(['git', 'fetch', 'origin', 'master'])
    p = run(['git', 'diff', 'FETCH_HEAD', '--name-only'])
    return [
        os.path.dirname(os.path.relpath(i, recipe_folder))
        for i in p.stdout.splitlines(False)
    ]


def _load_platform_metas(recipe, finalize=True):
    # check if package is noarch, if so, build only on linux
    # with temp_os, we can fool the MetaData if needed.
    platform = os.environ.get('OSTYPE', sys.platform)
    if platform.startswith("darwin"):
        platform = 'osx'
    elif platform == "linux-gnu":
        platform = "linux"

    config = load_conda_build_config(platform=platform)
    return platform, load_all_meta(recipe, config=config, finalize=finalize)


def _meta_subdir(meta):
    # logic extracted from conda_build.variants.bldpkg_path
    return 'noarch' if meta.noarch or meta.noarch_python else meta.config.host_subdir


def _get_pkg_key_build_meta_map(metas):
    key_build_meta = defaultdict(dict)
    for meta in metas:
        pkg_key = PackageKey(meta.name(), meta.version(), int(meta.build_number() or 0))
        pkg_build = PackageBuild(_meta_subdir(meta), meta.build_id())
        key_build_meta[pkg_key][pkg_build] = meta
    key_build_meta.default_factory = None
    return key_build_meta


def check_recipe_skippable(recipe, channel_packages, force=False):
    """
    Return True if the same number of builds (per subdir) defined by the recipe
    are already in channel_packages (and force is False).
    """
    if force:
        return False
    platform, metas = _load_platform_metas(recipe, finalize=False)
    key_build_meta = _get_pkg_key_build_meta_map(metas)
    num_existing_pkg_builds = sum(
        (
            Counter(
                (pkg_key, pkg_build.subdir)
                for pkg_build in channel_packages.get(pkg_key, set())
            )
            for pkg_key in key_build_meta.keys()
        ),
        Counter()
    )
    if num_existing_pkg_builds == Counter():
        # No packages with same version + build num in channels: no need to skip
        return False
    num_new_pkg_builds = sum(
        (
            Counter((pkg_key, pkg_build.subdir) for pkg_build in build_meta.keys())
            for pkg_key, build_meta in key_build_meta.items()
        ),
        Counter()
    )
    return num_new_pkg_builds == num_existing_pkg_builds


def _filter_existing_packages(metas, channel_packages):
    new_metas = []  # MetaData instances of packages not yet in channel
    existing_metas = []  # MetaData instances of packages already in channel
    divergent_builds = set()  # set of Dist (i.e., name-version-build) strings

    key_build_meta = _get_pkg_key_build_meta_map(metas)
    for pkg_key, build_meta in key_build_meta.items():
        existing_pkg_builds = channel_packages.get(pkg_key, set())
        for pkg_build, meta in build_meta.items():
            if pkg_build not in existing_pkg_builds:
                new_metas.append(meta)
            else:
                existing_metas.append(meta)
        for divergent_build in (existing_pkg_builds - set(build_meta.keys())):
            divergent_builds.add(
                '-'.join((pkg_key.name, pkg_key.version, divergent_build.build_id)))
    return new_metas, existing_metas, divergent_builds


def get_package_paths(recipe, channel_packages, force=False):
    if check_recipe_skippable(recipe, channel_packages, force):
        # NB: If we skip early here, we don't detect possible divergent builds.
        logger.info(
            'FILTER: not building recipe %s because '
            'the same number of builds are in channel(s) and it is not forced.',
            recipe)
        return []
    platform, metas = _load_platform_metas(recipe, finalize=True)

    # The recipe likely defined skip: True
    if not metas:
        return []

    # If on CI, handle noarch.
    if os.environ.get('CI', None) == 'true':
        first_meta = metas[0]
        if first_meta.get_value('build/noarch'):
            if platform != 'linux':
                logger.debug('FILTER: only building %s on '
                             'linux because it defines noarch.',
                             recipe)
                return []

    new_metas, existing_metas, divergent_builds = (
        _filter_existing_packages(metas, channel_packages))

    if divergent_builds:
        raise DivergentBuildsError(*sorted(divergent_builds))

    for meta in existing_metas:
        logger.info(
            'FILTER: not building %s because '
            'it is in channel(s) and it is not forced.', meta.pkg_fn())
    # yield all pkgs that do not yet exist
    if force:
        build_metas = new_metas + existing_metas
    else:
        build_metas = new_metas
    return list(chain.from_iterable(
        api.get_output_file_paths(meta) for meta in build_metas))


def get_all_channel_packages(channels):
    """
    Return a PackageKey -> set(PackageBuild) mapping.
    """
    if channels is None:
        channels = []

    all_channel_packages = defaultdict(set)
    for channel in channels:
        channel_packages = get_channel_packages(channel=channel)
        for pkg_key, pkg_builds in channel_packages.items():
            all_channel_packages[pkg_key].update(pkg_builds)
    all_channel_packages.default_factory = None
    return all_channel_packages


def get_blacklist(blacklists, recipe_folder):
    "Return list of recipes to skip from blacklists"
    blacklist = set()
    for p in blacklists:
        blacklist.update(
            [
                os.path.relpath(i.strip(), recipe_folder)
                for i in open(p, encoding='utf8')
                if not i.startswith('#') and i.strip()
            ]
        )
    return blacklist


def validate_config(config):
    """
    Validate config against schema

    Parameters
    ----------
    config : str or dict
        If str, assume it's a path to YAML file and load it. If dict, use it
        directly.
    """
    if not isinstance(config, dict):
        config = yaml.load(open(config))
    fn = pkg_resources.resource_filename(
        'bioconda_utils', 'config.schema.yaml'
    )
    schema = yaml.load(open(fn))
    validate(config, schema)


def load_config(path):
    """
    Parses config file, building paths to relevant blacklists

    Parameters
    ----------
    path : str
        Path to YAML config file
    """
    validate_config(path)

    if isinstance(path, dict):
        def relpath(p):
            return p
        config = path
    else:
        def relpath(p):
            return os.path.join(os.path.dirname(path), p)
        config = yaml.load(open(path))

    def get_list(key):
        # always return empty list, also if NoneType is defined in yaml
        value = config.get(key)
        if value is None:
            return []
        return value

    default_config = {
        'blacklists': [],
        'channels': [],
        'requirements': None,
        'upload_channel': 'bioconda'
    }
    if 'blacklists' in config:
        config['blacklists'] = [relpath(p) for p in get_list('blacklists')]
    if 'channels' in config:
        config['channels'] = get_list('channels')

    default_config.update(config)
    return default_config


def modified_recipes(git_range, recipe_folder, config_file):
    """
    Returns files under the recipes dir that have been modified within the git
    range. Includes meta.yaml files for recipes that have been unblacklisted in
    the git range. Filenames are returned with the `recipe_folder` included.

    git_range : list or tuple of length 1 or 2
        For example, ['00232ffe', '10fab113'], or commonly ['master', 'HEAD']
        or ['master']. If length 2, then the commits are provided to `git diff`
        using the triple-dot syntax, `commit1...commit2`. If length 1, the
        comparison is any changes in the working tree relative to the commit.

    recipe_folder : str
        Top-level recipes dir in which to search for meta.yaml files.
    """
    orig_git_range = git_range[:]
    if len(git_range) == 2:
        git_range = '...'.join(git_range)
    elif len(git_range) == 1 and isinstance(git_range, list):
        git_range = git_range[0]
    else:
        raise ValueError('Expected 1 or 2 args for git_range; got {}'.format(git_range))

    cmds = (
        [
            'git', 'diff', '--relative={}'.format(recipe_folder),
            '--name-only',
            git_range,
            "--"
        ] +
        [
            os.path.join(recipe_folder, '*'),
            os.path.join(recipe_folder, '*', '*')
        ]
    )

    # In versions >2 git expands globs. But if it's older than that we need to
    # run the command using shell=True to get the shell to expand globs.
    shell = False
    p = run(['git', '--version'])
    matches = re.match(r'^git version (?P<version>[\d\.]*)(?:.*)$', p.stdout)
    git_version = matches.group("version")
    if git_version < LooseVersion('2'):
        logger.warn(
            'git version (%s) is < 2.0. Running git diff using shell=True. '
            'Please consider upgrading git', git_version)
        cmds = ' '.join(cmds)
        shell = True

    p = run(cmds, shell=shell)

    modified = [
        os.path.join(recipe_folder, m)
        for m in p.stdout.strip().split('\n')
    ]

    # exclude recipes that were deleted in the git-range
    existing = list(filter(os.path.exists, modified))

    # if the only diff is that files were deleted, we can have ['recipes/'], so
    # filter on existing *files*
    existing = list(filter(os.path.isfile, existing))

    unblacklisted = newly_unblacklisted(config_file, recipe_folder, orig_git_range)
    unblacklisted = [os.path.join(recipe_folder, i, 'meta.yaml') for i in unblacklisted]
    existing += unblacklisted

    return existing


class Progress:
    def __init__(self):
        self.thread = Thread(target=self.progress)
        self.stop = Event()

    def progress(self):
        while not self.stop.wait(60):
            print(".", end="")
            sys.stdout.flush()
        print("")

    def __enter__(self):
        self.thread.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop.set()
        self.thread.join()
