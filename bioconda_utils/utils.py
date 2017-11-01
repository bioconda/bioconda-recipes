#!/usr/bin/env python

import os
import re
import glob
import fnmatch
import subprocess as sp
import sys
import shutil
import contextlib
from collections import defaultdict, Iterable
from itertools import product, chain, groupby
import logging
import pkg_resources
import networkx as nx
import requests
from jsonschema import validate
import datetime
from distutils.version import LooseVersion
import time
import threading

from conda_build import api
from conda_build.metadata import MetaData
from conda.version import VersionOrder
import yaml
from jinja2 import Environment, PackageLoader

logger = logging.getLogger(__name__)


jinja = Environment(
    loader=PackageLoader('bioconda_utils', 'templates'),
    trim_blocks=True,
    lstrip_blocks=True
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


def get_meta_value(meta, *keys, default=None):
    """
    Return value from metadata.
    Given keys can define a path in the document tree.
    """
    try:
        for key in keys:
            if not meta:
                raise KeyError(key)
            meta = meta[key]
        return meta
    except KeyError:
        return default


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


def load_all_meta(recipe, config):
    """
    For each environment, yield the rendered meta.yaml.
    """
    cfg = load_config(config)
    env_matrix = EnvMatrix(cfg['env_matrix'])
    for env in env_matrix:
        yield load_meta(recipe, env)


def load_meta(recipe, env):
    """
    Load metadata for a specific environment.
    """
    with temp_env(env):
        # Disabling set_build_id prevents the creation of uniquely-named work
        # directories just for checking the output file.
        # It needs to be done within the context manager so that it sees the
        # os.environ.
        config = api.Config(
            no_download_source=True,
            set_build_id=False)
        meta = MetaData(recipe, config=config)
        meta.parse_again()
        return meta.meta


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


def run(cmds, env=None, **kwargs):
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
        logger.error('COMMAND FAILED: %s', ' '.join(e.cmd))
        logger.error('STDOUT+STDERR:\n%s', e.stdout)
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


def get_deps(recipe, config, build=True):
    """
    Generator of dependencies for a single recipe

    Only names (not versions) of dependencies are yielded.

    Parameters
    ----------
    recipe : str or MetaData
        If string, it is a path to the recipe; otherwise assume it is a parsed
        conda_build.metadata.MetaData instance.

    build : bool
        If True yield build dependencies, if False yield run dependencies.
    """
    if isinstance(recipe, str):
        metadata = load_all_meta(recipe, config)

        # TODO: This function is currently used only for creating DAGs, but it's
        # unclear how to manage different dependencies depending on the
        # particular environment. For now, just use the first environment.
        metadata = list(metadata)
        metadata = metadata[0]
    else:
        metadata = recipe

    reqs = metadata.get('requirements', {})
    if build:
        deps = reqs.get('build', [])
    else:
        deps = reqs.get('run', [])
    for dep in deps:
        yield dep.split()[0]


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
    recipes = list(recipes)
    metadata = []
    for recipe in sorted(recipes):
        for r in list(load_all_meta(recipe, config)):
            metadata.append((r, recipe))
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
        name = meta['package']['name']
        if name not in blacklist:
            name2recipe[name].update([recipe])

    def get_inner_deps(dependencies):
        for dep in dependencies:
            name = dep.split()[0]
            if name in name2recipe or not restrict:
                yield name

    dag = nx.DiGraph()
    dag.add_nodes_from(meta['package']['name'] for meta, recipe in metadata)
    for meta, recipe in metadata:
        name = meta['package']['name']
        dag.add_edges_from((dep, name)
                           for dep in set(get_inner_deps(chain(
                               get_deps(meta, config=config),
                               get_deps(meta, config=config,
                                        build=False)))))

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
        logger.debug(
            "get_recipes(%s, package='%s'): %s", recipe_folder, package, p)
        path = os.path.join(recipe_folder, p)
        yield from map(os.path.dirname,
                       glob.glob(os.path.join(path, "meta.yaml")))
        yield from map(os.path.dirname,
                       glob.glob(os.path.join(path, "*", "meta.yaml")))


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
    env = list(EnvMatrix(config['env_matrix']))[0]
    recipes = sorted(get_recipes(recipe_folder, package), key=toplevel)

    for package, group in groupby(recipes, key=toplevel):
        group = list(group)
        if len(group) == 1:
            yield group[0]
        else:
            def get_version(p):
                return VersionOrder(
                    load_meta(os.path.join(p, 'meta.yaml'), env)['package']['version']
                )
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


def get_channel_packages(channel='bioconda', platform=None):
    """
    Retrieves the existing packages for a channel from conda.anaconda.org

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
    channel_packages = set(repodata['packages'].keys())
    channel_packages.update(noarch_repodata['packages'].keys())
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


def built_package_path(recipe, env=None):
    """
    Returns the path to which a recipe would be built.

    Does not necessarily exist; equivalent to `conda build --output recipename`
    but without the subprocess.
    """
    if env is None:
        env = {}
    env = dict(env)

    # Ensure CONDA_PY is an integer (needed by conda-build 2.0.4)
    py = env.get('CONDA_PY', None)
    env = dict(env)
    if py is not None:
        env['CONDA_PY'] = _string_or_float_to_integer_python(py)

    with temp_env(env):
        # Disabling set_build_id prevents the creation of uniquely-named work
        # directories just for checking the output file.
        # It needs to be done within the context manager so that it sees the
        # os.environ.
        config = api.Config(
            no_download_source=True,
            set_build_id=False)
        meta = MetaData(recipe, config=config)
        meta.parse_again()
        path = api.get_output_file_path(meta, config=config)
    return path


class Target:
    def __init__(self, pkg, env):
        """
        Class to represent a package built with a particular environment
        (e.g. from EnvMatirix).
        """
        self.pkg = pkg
        self.env = env

    def __hash__(self):
        return self.pkg.__hash__()

    def __eq__(self, other):
        return self.pkg == other.pkg

    def __str__(self):
        return os.path.basename(self.pkg)

    def envstring(self):
        return ';'.join(['='.join([i, str(j)]) for i, j in self.env])


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


def filter_recipes(recipes, env_matrix, channels=None, force=False):
    """
    Generator yielding only those recipes that should be built.

    Parameters
    ----------
    recipes : iterable
        Iterable of candidate recipes

    env_matrix : str, dict, or EnvMatrix
        If str or dict, create an EnvMatrix; if EnvMatrix already use it as-is.

    channels : None or list
        Optional list of channels to check for existing recipes

    force : bool
        Build the package even if it is already available in supplied channels.
    """
    if not isinstance(env_matrix, EnvMatrix):
        env_matrix = EnvMatrix(env_matrix)

    if channels is None:
        channels = []

    channel_packages = defaultdict(set)
    for channel in channels:
        channel_packages[channel].update(get_channel_packages(channel=channel))

    def tobuild(recipe, env):
        pkg = os.path.basename(built_package_path(recipe, env))

        in_channels = [
            channel for channel, pkgs in channel_packages.items()
            if pkg in pkgs
        ]
        if in_channels and not force:
            logger.debug(
                'FILTER: not building %s because '
                'it is in channel(s) and it is not forced: %s', pkg,
                in_channels)
            return False

        # with temp_env, MetaData will see everything in env added to
        # os.environ.
        with temp_env(env):

            # with temp_os, we can fool the MetaData if needed.
            platform = os.environ.get('TRAVIS_OS_NAME', sys.platform)

            # TRAVIS_OS_NAME uses 'osx', but sys.platform uses 'darwin', and
            # that's what conda will be looking for.
            if platform == 'osx':
                platform = 'darwin'

            with temp_os(platform):
                meta = MetaData(recipe)
                if meta.skip():
                    logger.debug(
                        'FILTER: not building %s because '
                        'it defines skip for this env', pkg)
                    return False

                # If on travis, handle noarch.
                if os.environ.get('TRAVIS', None) == 'true':
                    if meta.get_value('build/noarch'):
                        if platform != 'linux':
                            logger.debug('FILTER: only building %s on '
                                         'linux because it defines noarch.',
                                         pkg)
                            return False

        assert not pkg.endswith("_.tar.bz2"), (
            "rendered path {} does not "
            "contain a build number and recipe does not "
            "define skip for this environment. "
            "This is a conda bug.".format(pkg))

        logger.debug(
            'FILTER: building %s because it is not in channels and '
            'does not define skip', pkg)
        return True

    logger.debug('recipes: %s', recipes)
    recipes = list(recipes)
    nrecipes = len(recipes)
    if nrecipes == 0:
        raise StopIteration
    max_recipe = max(map(len, recipes))
    template = (
        'Filtering {{0}} of {{1}} ({{2:.1f}}%) {{3:<{0}}}'.format(max_recipe)
    )
    print(flush=True)
    try:
        for i, recipe in enumerate(sorted(recipes)):
            perc = (i + 1) / nrecipes * 100
            print(template.format(i + 1, nrecipes, perc, recipe), end='')
            targets = set()
            for env in env_matrix:
                pkg = built_package_path(recipe, env)
                if tobuild(recipe, env):
                    targets.update([Target(pkg, env)])
            if targets:
                yield recipe, targets
            print(end='\r')
    except sp.CalledProcessError as e:
        logger.debug(e.stdout)
        logger.error(e.stderr)
        exit(1)
    finally:
        print(flush=True)


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
    Parses config file, building paths to relevant blacklists and loading any
    specified env_matrix files.

    Parameters
    ----------
    path : str
        Path to YAML config file
    """
    validate_config(path)

    if isinstance(path, dict):
        config = path
        relpath = lambda p: p
    else:
        config = yaml.load(open(path))
        relpath = lambda p: os.path.join(os.path.dirname(path), p)

    def get_list(key):
        # always return empty list, also if NoneType is defined in yaml
        value = config.get(key)
        if value is None:
            return []
        return value

    default_config = {
        'env_matrix': {'CONDA_PY': 35},
        'blacklists': [],
        'channels': [],
        'docker_image': 'condaforge/linux-anvil',
        'requirements': None,
        'upload_channel': 'bioconda'
    }
    if 'env_matrix' in config:
        if isinstance(config['env_matrix'], str):
            config['env_matrix'] = relpath(config['env_matrix'])
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
        self.thread = threading.Thread(target=self.progress)
        self.stop = False

    def progress(self):
        while not self.stop:
            print(".", end="")
            sys.stdout.flush()
            time.sleep(60)
        print("")

    def __enter__(self):
        self.thread.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop = True
        self.thread.join()
