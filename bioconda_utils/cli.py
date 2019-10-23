"""
Bioconda Utils Command Line Interface

"""

# Workaround for spurious numpy warning message
# ".../importlib/_bootstrap.py:219: RuntimeWarning: numpy.dtype size \
# changed, may indicate binary incompatibility. Expected 96, got 88"
import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")

import sys
import os
import shlex
import logging
from collections import defaultdict, Counter
from functools import partial
import inspect
from typing import List, Tuple

import argh
from argh import arg, named
import networkx as nx
from networkx.drawing.nx_pydot import write_dot
import pandas

from . import __version__ as VERSION
from . import utils
from .build import build_recipes
from . import docker_utils
from . import lint
from . import bioconductor_skeleton as _bioconductor_skeleton
from . import cran_skeleton
from . import update_pinnings
from . import graph
from .githandler import BiocondaRepo, install_gpg_key

logger = logging.getLogger(__name__)


def enable_logging(default_loglevel='info', default_file_loglevel='debug'):
    """Adds the parameter ``--loglevel`` and sets up logging

    Args:
      default_loglevel: loglevel used when --loglevel is not passed
    """
    def decorator(func):
        @arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
        @arg('--logfile', help="Write log to file")
        @arg('--logfile-level', help="Log level for log file")
        @arg('--log-command-max-lines', help="Limit lines emitted for commands executed")
        @utils.wraps(func)
        def wrapper(*args, loglevel=default_loglevel, logfile=None,
                    logfile_level=default_file_loglevel,
                    log_command_max_lines=None, **kwargs):
            max_lines = int(log_command_max_lines) if log_command_max_lines else None
            utils.setup_logger('bioconda_utils', loglevel, logfile, logfile_level,
                               max_lines)
            func(*args, **kwargs)
        return wrapper
    return decorator


def enable_debugging():
    """Adds the paremeter ``--pdb`` (or ``-P``) to enable dropping into PDB"""
    def decorator(func):
        @arg('-P', '--pdb', help="Drop into debugger on exception")
        @utils.wraps(func)
        def wrapper(*args, pdb=False, **kwargs):
            try:
                func(*args, **kwargs)
            except Exception as e:
                logger.exception("Dropping into debugger")
                if pdb:
                    import pdb
                    pdb.post_mortem()
                else:
                    raise
        return wrapper
    return decorator


def enable_threads():
    """Adds the parameter ``--threads`` (or ``-t``) to limit parallelism"""
    def decorator(func):
        @arg('-t', '--threads', help="Limit maximum number of processes used.")
        @utils.wraps(func)
        def wrapper(*args, threads=16, **kwargs):
            utils.set_max_threads(threads)
            func(*args, **kwargs)
        return wrapper
    return decorator


def recipe_folder_and_config(allow_missing_for=None):
    """Adds optional positional arguments recipe_folder and config

    Requires that func has synopsis ``def x(recipe_folder, config,...)``.
    """
    def check_arg(args, idx, name, default, allow_missing):
        val = args[idx]
        if not val:
            val = default
        if not os.path.exists(val) and not allow_missing:
            sys.exit(f"Argument '{name}' points to missing file '{val}'")
        if val != args[idx]:
            lst = list(args)
            lst[idx] = val
            return tuple(lst)
        return args

    def decorator(func):
        args = inspect.getfullargspec(func).args
        try:
            recipe_folder_idx = args.index('recipe_folder')
            config_idx = args.index('config')
            allow_missing_idx = [args.index(field)
                                 for field in allow_missing_for or []]
        except ValueError:
            sys.exit(f"Function {func} must have 'recipe_folder' and 'config' args")
        @arg('recipe_folder', nargs='?',
             help='Path to folder containing recipes (default: recipes/)')
        @arg('config', nargs='?',
             help='Path to Bioconda config (default: config.yml)')
        @utils.wraps(func)
        def wrapper(*args, **kwargs):
            allow = any(args[idx] for idx in allow_missing_idx)
            args = check_arg(args, recipe_folder_idx, 'recipe_folder', 'recipes/', allow)
            args = check_arg(args, config_idx, 'config', 'config.yml', allow)
            func(*args, **kwargs)
        return wrapper
    return decorator


def get_recipes_to_build(git_range: Tuple[str], recipe_folder: str) -> List[str]:
    """Gets list of modified recipes according to git_range and blacklist

    See `BiocondaRepoMixin.get_recipes_to_build()`.

    Arguments:
      git_range: one or two-tuple containing "from" and "to" git refs,
                 with "to" defaulting to "HEAD"
    Returns:
      List of recipes for which meta.yaml or build.sh was modified or
      which were unblacklisted.
    """
    if not git_range or len(git_range) > 2:
        sys.exit("--git-range may have only one or two arguments")
    other = git_range[0]
    ref = "HEAD" if len(git_range) == 1 else git_range[1]
    repo = BiocondaRepo(recipe_folder)
    return repo.get_recipes_to_build(ref, other)


def get_recipes(config, recipe_folder, packages, git_range) -> List[str]:
    """Gets list of paths to recipe folders to be built

    Considers all recipes matching globs in packages, constrains to
    recipes modified or unblacklisted in the git_range if given, then
    removes blacklisted recipes.

    """
    recipes = list(utils.get_recipes(recipe_folder, packages))
    logger.info("Considering total of %s recipes%s.",
                len(recipes), utils.ellipsize_recipes(recipes, recipe_folder))

    if git_range:
        changed_recipes = get_recipes_to_build(git_range, recipe_folder)
        logger.info("Constraining to %s git modified recipes%s.", len(changed_recipes),
                    utils.ellipsize_recipes(changed_recipes, recipe_folder))
        recipes = [recipe for recipe in recipes if recipe in set(changed_recipes)]
        if len(recipes) != len(changed_recipes):
            logger.info("Overlap was %s recipes%s.", len(recipes),
                        utils.ellipsize_recipes(recipes, recipe_folder))

    blacklist = utils.get_blacklist(config, recipe_folder)
    blacklisted = []
    for recipe in recipes:
        if os.path.relpath(recipe, recipe_folder) in blacklist:
            blacklisted.append(recipe)
    if blacklisted:
        logger.info("Ignoring %s blacklisted recipes%s.", len(blacklisted),
                    utils.ellipsize_recipes(blacklisted, recipe_folder))
        recipes = [recipe for recipe in recipes if recipe not in set(blacklisted)]
    logger.info("Processing %s recipes%s.", len(recipes),
                utils.ellipsize_recipes(recipes, recipe_folder))
    return recipes


# NOTE:
#
# A package is the name of the software package, like `bowtie`.
#
# A recipe is the path to the recipe of one version of a package, like
# `recipes/bowtie` or `recipes/bowtie/1.0.1`.


@arg('config', help='Path to yaml file specifying the configuration')
@arg('--strict-version', action='store_true', help='Require version to strictly match.')
@arg('--strict-build', action='store_true', help='Require version and build to strictly match.')
@arg('--remove', action='store_true', help='Remove packages from anaconda.')
@arg('--dryrun', '-n', action='store_true', help='Only print removal plan.')
@arg('--url', action='store_true', help='Print anaconda urls.')
@arg('--channel', help="Channel to check for duplicates")
@enable_logging()
def duplicates(config,
               strict_version=False,
               strict_build=False,
               dryrun=False,
               remove=False,
               url=False,
               channel='bioconda'):
    """
    Detect packages in bioconda that have duplicates in the other defined
    channels.
    """
    if remove and not strict_build:
        raise ValueError('Removing packages is only supported in case of '
                         '--strict-build.')

    config = utils.load_config(config)
    if channel not in config['channels']:
        raise ValueError("Channel given with --channel must be in config channels")
    our_channel = channel
    channels = [c for c in config['channels'] if c != our_channel]
    logger.info("Checking for packages from %s also present in %s",
                our_channel, channels)

    check_fields = ['name']
    if strict_version or strict_build:
        check_fields += ['version']
    if strict_build:
        check_fields += ['build']

    def remove_package(spec):
        fn = '{}-{}-{}.tar.bz2'.format(*spec)
        name, version = spec[:2]
        subcmd = [
            'remove', '-f',
            '{channel}/{name}/{version}/{fn}'.format(
                name=name, version=version, fn=fn, channel=our_channel
            )
        ]
        if dryrun:
            logger.info(" ".join([utils.bin_for('anaconda')] + subcmd))
        else:
            token = os.environ.get('ANACONDA_TOKEN')
            if token is None:
                token = []
            else:
                token = ['-t', token]
            logger.info(utils.run([utils.bin_for('anaconda')] + token + subcmd, mask=[token]).stdout)

    # packages in our channel
    repodata = utils.RepoData()
    our_package_specs = set(repodata.get_package_data(check_fields, our_channel))
    logger.info("%s unique packages specs to consider in %s",
                len(our_package_specs), our_channel)

    # packages in channels we depend on
    duplicate = defaultdict(list)
    for channel in channels:
        package_specs = set(repodata.get_package_data(check_fields, channel))
        logger.info("%s unique packages specs to consider in %s",
                    len(package_specs), channel)
        dups = our_package_specs & package_specs
        logger.info("  (of which %s are duplicate)", len(dups))
        for spec in dups:
            duplicate[spec].append(channel)

    print('\t'.join(check_fields + ['channels']))
    for spec, dup_channels in sorted(duplicate.items()):
        if remove:
            remove_package(spec)
        else:
            if url:
                if not strict_version and not strict_build:
                    print('https://anaconda.org/{}/{}'.format(
                          our_channel, spec[0]))
                print('https://anaconda.org/{}/{}/files?version={}'.format(
                    our_channel, *spec))
            else:
                print(*spec, ','.join(dup_channels), sep='\t')


@recipe_folder_and_config(allow_missing_for=['list_checks'])
@arg(
    '--packages',
    nargs="+",
    help='Glob for package[s] to build. Default is to build all packages. Can '
    'be specified more than once')
@arg('--cache', help='''To speed up debugging, use repodata cached locally in
     the provided filename. If the file does not exist, it will be created the
     first time.''')
@arg('--list-checks', help='''List the linting functions to be used and then
     exit''')
@arg('--exclude', nargs='+', help='''Exclude this linting function. Can be used
     multiple times.''')
@arg('--push-status', action='store_true', help='''If set, the lint status will
     be sent to the current commit on github. Also needs --user and --repo to
     be set. Requires the env var GITHUB_TOKEN to be set. Note that pull
     requests from forks will not have access to encrypted variables on
     ci, so this feature may be of limited use.''')
@arg('--commit', help='Commit on github on which to update status')
@arg('--push-comment', action='store_true', help='''If set, the lint status
     will be posted as a comment in the corresponding pull request (given by
     --pull-request). Also needs --user and --repo to be set. Requires the env
     var GITHUB_TOKEN to be set.''')
@arg('--pull-request', type=int, help='''Pull request id on github on which to
     post a comment.''')
@arg('--user', help='Github user')
@arg('--repo', help='Github repo')
@arg('--git-range', nargs='+',
     help='''Git range (e.g. commits or something like
     "master HEAD" to check commits in HEAD vs master, or just "HEAD" to
     include uncommitted changes). All recipes modified within this range will
     be built if not present in the channel.''')
@arg('--full-report', action='store_true', help='''Default behavior is to
     summarize the linting results; use this argument to get the full
     results as a TSV printed to stdout.''')
@arg('--try-fix', help='''Attempt to fix problems where found''')
@enable_logging()
@enable_debugging()
@named('lint')
def do_lint(recipe_folder, config, packages="*", cache=None, list_checks=False,
            exclude=None, push_status=False, user='bioconda',
            commit=None, push_comment=False, pull_request=None,
            repo='bioconda-recipes', git_range=None, full_report=False,
            try_fix=False):
    """
    Lint recipes

    If --push-status is not set, reports a TSV of linting results to stdout.
    Otherwise pushes a commit status to the specified commit on github.
    """
    if list_checks:
        print('\n'.join(str(check) for check in lint.get_checks()))
        sys.exit(0)

    config = utils.load_config(config)

    if cache is not None:
        utils.RepoData().set_cache(cache)

    recipes = get_recipes(config, recipe_folder, packages, git_range)
    linter = lint.Linter(config, recipe_folder, exclude)
    result = linter.lint(recipes, fix=try_fix)
    messages = linter.get_messages()

    if messages:
        print("The following problems have been found:\n")
        print(linter.get_report())

    if not result:
        print("All checks OK")
    else:
        sys.exit("Errors were found")


@recipe_folder_and_config()
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to build. Default is to build all packages. Can '
    'be specified more than once')
@arg('--git-range', nargs='+',
     help='''Git range (e.g. commits or something like
     "master HEAD" to check commits in HEAD vs master, or just "HEAD" to
     include uncommitted changes). All recipes modified within this range will
     be built if not present in the channel.''')
@arg('--testonly', help='Test packages instead of building')
@arg('--force',
     help='''Force building the recipe even if it already exists in the
     bioconda channel. If --force is specified, --git-range is ignored and only
     those packages matching --packages globs will be built.''')
@arg('--docker', action='store_true',
     help='Build packages in docker container.')
@arg('--mulled-test', action='store_true', help="Run a mulled-build test on the built package")
@arg('--mulled-upload-target', help="Provide a quay.io target to push mulled docker images to.")
@arg('--build_script_template', help='''Filename to optionally replace build
     script template used by the Docker container. By default use
     docker_utils.BUILD_SCRIPT_TEMPLATE. Only used if --docker is True.''')
@arg('--pkg_dir', help='''Specifies the directory to which container-built
     packages should be stored on the host. Default is to use the host's
     conda-bld dir. If --docker is not specified, then this argument is
     ignored.''')
@arg('--anaconda-upload', action='store_true', help='''After building recipes, upload
     them to Anaconda. This requires $ANACONDA_TOKEN to be set.''')
@arg('--build-image', action='store_true', help='''Build temporary docker build
     image with conda/conda-build version matching local versions''')
@arg('--keep-image', action='store_true', help='''After building recipes, the
     created Docker image is removed by default to save disk space. Use this
     argument to disable this behavior.''')
@arg('--lint', '--prelint', action='store_true', help='''Just before each recipe, apply
     the linting functions to it. This can be used as an alternative to linting
     all recipes before any building takes place with the `bioconda-utils lint`
     command.''')
@arg('--lint-exclude', nargs='+',
     help='''Exclude this linting function. Can be used multiple times.''')
@arg('--check-channels', nargs='+',
     help='''Channels to check recipes against before building. Any recipe
     already present in one of these channels will be skipped. The default is
     the first two channels specified in the config file. Note that this is
     ignored if you specify --git-range.''')
@arg('--n-workers', type=int, default=1,
     help='''The number of parallel workers that are in use. This is intended
     for use in cases such as the "bulk" branch, where there are multiple
     parallel workers building and uploading recipes. In essence, this causes
     bioconda-utils to process every Nth sub-DAG, where N is the value you give
     to this option. The default is 1, which is intended for cases where there
     are NOT parallel workers (i.e., the majority of cases). This should
     generally NOT be used in conjunctions with the --packages or --git-range
     options!''')
@arg('--worker-offset', type=int, default=0,
     help='''This is only used if --nWorkers is >1. In that case, then each
     instance of bioconda-utils will process every Nth sub-DAG. This option
     gives the 0-based offset for that. For example, if "--n-workers 5 --worker-offset 0"
     is used, then this instance of bioconda-utils will process the 1st, 6th,
     11th, etc. sub-DAGs. Equivalently, using "--n-workers 5 --worker-offset 1"
     will result in sub-DAGs 2, 7, 12, etc. being processed. If you use more
     than one worker, then make sure to give each a different offset!''')
@arg('--keep-old-work', action='store_true', help='''Do not remove anything
from environment, even after successful build and test.''')
@enable_logging()
def build(recipe_folder, config, packages="*", git_range=None, testonly=False,
          force=False, docker=None, mulled_test=False, build_script_template=None,
          pkg_dir=None, anaconda_upload=False, mulled_upload_target=None,
          build_image=False, keep_image=False, lint=False, lint_exclude=None,
          check_channels=None, n_workers=1, worker_offset=0, keep_old_work=False):
    cfg = utils.load_config(config)
    setup = cfg.get('setup', None)
    if setup:
        logger.debug("Running setup: %s", setup)
        for cmd in setup:
            utils.run(shlex.split(cmd), mask=False)

    recipes = get_recipes(cfg, recipe_folder, packages, git_range)

    if docker:
        if build_script_template is not None:
            build_script_template = open(build_script_template).read()
        else:
            build_script_template = docker_utils.BUILD_SCRIPT_TEMPLATE
        if pkg_dir is None:
            use_host_conda_bld = True
        else:
            use_host_conda_bld = False

        docker_builder = docker_utils.RecipeBuilder(
            build_script_template=build_script_template,
            pkg_dir=pkg_dir,
            use_host_conda_bld=use_host_conda_bld,
            keep_image=keep_image,
            build_image=build_image,
        )
    else:
        docker_builder = None

    if lint_exclude and not lint:
        logger.warning('--lint-exclude has no effect unless --lint is specified.')

    label = os.getenv('BIOCONDA_LABEL', None) or None

    success = build_recipes(recipe_folder, config, recipes,
                            testonly=testonly,
                            force=force,
                            mulled_test=mulled_test,
                            docker_builder=docker_builder,
                            anaconda_upload=anaconda_upload,
                            mulled_upload_target=mulled_upload_target,
                            do_lint=lint,
                            lint_exclude=lint_exclude,
                            check_channels=check_channels,
                            label=label,
                            n_workers=n_workers,
                            worker_offset=worker_offset,
                            keep_old_work=keep_old_work)
    exit(0 if success else 1)


@recipe_folder_and_config()
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to show in DAG. Default is to show all '
     'packages. Can be specified more than once')
@arg('--format', choices=['gml', 'dot', 'txt'], help='''Set format to print
     graph. "gml" and "dot" can be imported into graph visualization tools
     (graphviz, gephi, cytoscape). "txt" will print out recipes grouped by
     independent subdags, largest subdag first, each in topologically sorted
     order. Singleton subdags (if not hidden with --hide-singletons) are
     reported as one large group at the end.''')
@arg('--hide-singletons',
     action='store_true',
     help='Hide singletons in the printed graph.')
@enable_logging()
def dag(recipe_folder, config, packages="*", format='gml', hide_singletons=False):
    """
    Export the DAG of packages to a graph format file for visualization
    """
    dag, name2recipes = graph.build(utils.get_recipes(recipe_folder, "*"), config)
    if packages != "*":
        dag = graph.filter(dag, packages)
    if hide_singletons:
        for node in nx.nodes(dag):
            if dag.degree(node) == 0:
                dag.remove_node(node)
    if format == 'gml':
        nx.write_gml(dag, sys.stdout.buffer)
    elif format == 'dot':
        write_dot(dag, sys.stdout)
    elif format == 'txt':
        subdags = sorted(map(sorted, nx.connected_components(dag.to_undirected())))
        subdags = sorted(subdags, key=len, reverse=True)
        singletons = []
        for i, s in enumerate(subdags):
            if len(s) == 1:
                singletons += s
                continue
            print("# subdag {0}".format(i))
            subdag = dag.subgraph(s)
            recipes = [
                recipe for package in nx.topological_sort(subdag)
                for recipe in name2recipes[package]]
            print('\n'.join(recipes) + '\n')
        if not hide_singletons:
            print('# singletons')
            recipes = [recipe for package in singletons for recipe in
                       name2recipes[package]]
            print('\n'.join(recipes) + '\n')


@recipe_folder_and_config()
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to update, as needed due to a change in pinnings')
@arg('--skip-additional-channels',
     nargs='*',
     help="""Skip updating/bumping packges that are already built with
     compatible pinnings in one of the given channels in addition to those
     listed in 'config'.""")
@arg('--bump-only-python',
     help="""Bump package build numbers even if the only applicable pinning
     change is the python version. This is generally required unless you plan
     on building everything.""")
@arg('--cache', help='''To speed up debugging, use repodata cached locally in
     the provided filename. If the file does not exist, it will be created the
     first time.''')
@enable_logging()
@enable_threads()
@enable_debugging()
def update_pinning(recipe_folder, config, packages="*",
                   skip_additional_channels=None,
                   bump_only_python=False,
                   cache=None):
    """Bump a package build number and all dependencies as required due
    to a change in pinnings
    """
    config = utils.load_config(config)
    if skip_additional_channels:
        config['channels'] += skip_additional_channels

    if cache:
        utils.RepoData().set_cache(cache)
    utils.RepoData().df  # trigger load

    build_config = utils.load_conda_build_config()
    blacklist = utils.get_blacklist(config, recipe_folder)

    from . import recipe
    dag = graph.build_from_recipes(
        recip for recip in recipe.load_parallel_iter(recipe_folder, "*")
        if recip.reldir not in blacklist)

    dag = graph.filter_recipe_dag(dag, packages, [])

    logger.warning("Considering %i recipes", len(dag))

    stats = Counter()
    hadErrors = set()
    bumpErrors = set()

    needs_bump = partial(update_pinnings.check, build_config=build_config)

    State = update_pinnings.State

    for status, recip in zip(utils.parallel_iter(needs_bump, dag, "Processing..."), dag):
        logger.debug("Recipe %s status: %s", recip, status)
        stats[status] += 1
        if status.needs_bump(bump_only_python):
            logger.info("Bumping %s", recip)
            recip.reset_buildnumber(int(recip['build']['number'])+1)
            recip.save()
        elif status.failed():
            logger.info("Failed to inspect %s", recip)
            hadErrors.add(recipe)
        else:
            logger.info('OK: %s', recip)

    # Print some information
    print("Packages requiring the following:")
    print(stats)
    #print("  No build number change needed: {}".format(stats[STATE.ok]))
    #print("  A rebuild for a new python version: {}".format(stats[STATE.bump_python]))
    #print("  A build number increment: {}".format(stats[STATE.bump]))

    if hadErrors:
        print("{} packages produced an error "
              "in conda-build: {}".format(len(hadErrors), list(hadErrors)))

    if bumpErrors:
        print("The build numbers in the following recipes "
              "could not be incremented: {}".format(list(bumpErrors)))


@recipe_folder_and_config()
@arg('--dependencies', nargs='+',
     help='''Return recipes in `recipe_folder` in the dependency chain for the
     packages listed here. Answers the question "what does PACKAGE need?"''')
@arg('--reverse-dependencies', nargs='+',
     help='''Return recipes in `recipe_folder` in the reverse dependency chain
     for packages listed here. Answers the question "what depends on
     PACKAGE?"''')
@arg('--restrict',
     help='''Restrict --dependencies to packages in `recipe_folder`. Has no
     effect if --reverse-dependencies, which always looks just in the recipe
     dir.''')
@enable_logging()
def dependent(recipe_folder, config, restrict=False,
              dependencies=None, reverse_dependencies=None):
    """
    Print recipes dependent on a package
    """
    if dependencies and reverse_dependencies:
        raise ValueError(
            '`dependencies` and `reverse_dependencies` are mutually exclusive')
    if not any([dependencies, reverse_dependencies]):
        raise ValueError(
            'One of `--dependencies` or `--reverse-dependencies` is required.')

    d, n2r = graph.build(utils.get_recipes(recipe_folder, "*"), config, restrict=restrict)

    if reverse_dependencies is not None:
        func, packages = nx.algorithms.descendants, reverse_dependencies
    elif dependencies is not None:
        func, packages = nx.algorithms.ancestors, dependencies

    pkgs = []
    for pkg in packages:
        pkgs.extend(list(func(d, pkg)))
    print('\n'.join(sorted(list(set(pkgs)))))


@arg('package', help='''Bioconductor package name. This is case-sensitive, and
     must match the package name on the Bioconductor site. If "update-all-packages"
     is specified, then all packages in a given bioconductor release will be
     created/updated (--force is then implied).''')
@recipe_folder_and_config()
@arg('--versioned', action='store_true', help='''If specified, recipe will be
     created in RECIPES/<package>/<version>''')
@arg('--force', action='store_true', help='''Overwrite the contents of an
     existing recipe. If --recursive is also used, then overwrite *all* recipes
     created.''')
@arg('--pkg-version', help='''Package version to use instead of the current
     one''')
@arg('--bioc-version', help="""Version of Bioconductor to target. If not
     specified, then automatically finds the latest version of Bioconductor
     with the specified version in --pkg-version, or if --pkg-version not
     specified, then finds the the latest package version in the latest
     Bioconductor version""")
@arg('--recursive', action='store_true', help="""Creates the recipes for all
     Bioconductor and CRAN dependencies of the specified package.""")
@arg('--skip-if-in-channels', nargs='*', help="""When --recursive is used, it will build
     *all* recipes. Use this argument to skip recursive building for packages
     that already exist in the packages listed here.""")
@enable_logging('debug')
def bioconductor_skeleton(
    recipe_folder, config, package, versioned=False, force=False,
    pkg_version=None, bioc_version=None, recursive=False,
    skip_if_in_channels=['conda-forge', 'bioconda']):
    """
    Build a Bioconductor recipe. The recipe will be created in the 'recipes'
    directory and will be prefixed by "bioconductor-". If --recursive is set,
    then any R dependency recipes will be prefixed by "r-".

    These R recipes must be evaluated on a case-by-case basis to determine if
    they are relevant to biology (in which case they should be submitted to
    bioconda) or not (submit to conda-forge).

    Biology-related:
        'bioconda-utils clean-cran-skeleton <recipe> --no-windows'
        and submit to Bioconda.

    Not bio-related:
        'bioconda-utils clean-cran-skeleton <recipe>'
        and submit to conda-forge.

    """
    seen_dependencies = set()

    if package == "update-all-packages":
        if not bioc_version:
            bioc_version = _bioconductor_skeleton.latest_bioconductor_release_version()
        packages = _bioconductor_skeleton.fetchPackages(bioc_version)
        needs_x = _bioconductor_skeleton.packagesNeedingX(packages)
        problems = []
        for k, v in packages.items():
            try:
                _bioconductor_skeleton.write_recipe(
                    k, recipe_folder, config, force=True, bioc_version=bioc_version,
                    pkg_version=v['Version'], versioned=versioned, packages=packages,
                    skip_if_in_channels=skip_if_in_channels, needs_x = k in needs_x)
            except:
                problems.append(k)
        if len(problems):
            sys.exit("The following recipes had problems and were not finished: {}".format(", ".join(problems)))
    else:
        _bioconductor_skeleton.write_recipe(
            package, recipe_folder, config, force=force, bioc_version=bioc_version,
            pkg_version=pkg_version, versioned=versioned, recursive=recursive,
            seen_dependencies=seen_dependencies,
            skip_if_in_channels=skip_if_in_channels)


@arg('recipe', help='''Path to recipe to be cleaned''')
@arg('--no-windows', action='store_true', help="""Use this when submitting an
     R package to Bioconda. After a CRAN skeleton is created, any
     Windows-related lines will be removed and the bld.bat file will be
     removed.""")
@enable_logging()
def clean_cran_skeleton(recipe, no_windows=False):
    """
    Cleans skeletons created by ``conda skeleton cran``.

    Before submitting to conda-forge or Bioconda, recipes generated with ``conda
    skeleton cran`` need to be cleaned up: comments removed, licenses fixed, and
    other linting.

    Use --no-windows for a Bioconda submission.
    """
    cran_skeleton.clean_skeleton_files(recipe, no_windows=no_windows)


@arg('recipe_folder', help='Path to recipes directory')
@arg('config', help='Path to yaml file specifying the configuration')
@recipe_folder_and_config()
@arg('--packages', nargs="+",
     help='Glob(s) for package[s] to scan. Can be specified more than once')
@arg('--exclude', nargs="+",
     help='Globs for package[s] to exclude from scan. Can be specified more than once')
@arg('--exclude-subrecipes', help='''By default, only subrecipes explicitly
     enabled for watch in meta.yaml are considered. Set to 'always' to
     exclude all subrecipes.  Set to 'never' to include all subrecipes''')
@arg('--exclude-channels', nargs="+", help='''Exclude recipes
     building packages present in other channels. Set to 'none' to disable
     check.''')
@arg('--ignore-blacklists', help='''Do not exclude recipes from blacklist''')
@arg('--fetch-requirements',
     help='''Try to fetch python requirements. Please note that this requires
     downloading packages and executing setup.py, so presents a potential
     security problem.''')
@arg('--cache', help='''To speed up debugging, use repodata cached locally in
     the provided filename. If the file does not exist, it will be created
     the first time. Caution: The cache will not be updated if
     exclude-channels is changed''')
@arg('--unparsed-urls', help='''Write unrecognized urls to this file''')
@arg('--failed-urls', help='''Write urls with permanent failure to this file''')
@arg('--recipe-status', help='''Write status for each recipe to this file''')
@arg('--check-branch', help='''Check if recipe has active branch''')
@arg("--only-active", action="store_true", help="Check only recipes with active update")
@arg("--create-branch", action="store_true", help='''Create branch for each
     update''')
@arg("--create-pr", action="store_true", help='''Create PR for each update.
     Implies create-branch.''')
@arg("--max-updates", help='''Exit after ARG updates''')
@arg("--no-shuffle", help='''Do not shuffle recipe order''')
@arg("--dry-run", help='''Don't update remote git or github"''')
@arg("--no-check-pinnings", help='''Don't check for pinning updates''')
@arg("--no-follow-graph",
     help='''Don't process recipes in graph order or add dependent recipes
     to checks. Implies --no-skip-pending-deps.''')
@arg("--no-check-pending-deps",
     help='''Don't check for recipes having a dependency with a pending update.
     Update all recipes, including those having deps in need or rebuild.''')
@arg("--no-check-version-update",
     help='''Don't check for version updates to recipes''')
@arg('--bump-only-python',
     help="""Bump package build numbers even if the only applicable pinning
     change is the python version. This is generally required unless you plan
     on building everything.""")
@arg('--sign', nargs="?", help='''Enable signing. Optionally takes keyid.''')
@arg('--commit-as', nargs=2, help='''Set user and email to use for committing. '''
     '''Takes exactly two arguments.''')
@enable_logging()
@enable_debugging()
@enable_threads()
def autobump(recipe_folder, config, packages='*', exclude=None, cache=None,
             failed_urls=None, unparsed_urls=None, recipe_status=None,
             exclude_subrecipes=None, exclude_channels='conda-forge',
             ignore_blacklists=False,
             fetch_requirements=False,
             check_branch=False, create_branch=False, create_pr=False,
             only_active=False, no_shuffle=False,
             max_updates=0, dry_run=False,
             no_check_pinnings=False, no_follow_graph=False,
             no_check_version_update=False,
             no_check_pending_deps=False, bump_only_python=False,
             sign=0, commit_as=None):
    """
    Updates recipes in recipe_folder
    """
    # load and register config
    config_dict = utils.load_config(config)
    from . import autobump
    from . import githubhandler
    from . import hosters

    if no_follow_graph:
        recipe_source = autobump.RecipeSource(
            recipe_folder, packages, exclude or [], not no_shuffle)
        no_skip_pending_deps = True
    else:
        recipe_source = autobump.RecipeGraphSource(
            recipe_folder, packages, exclude, not no_shuffle,
            config_dict, cache_fn=cache and cache + "_dag.pkl")

    # Setup scanning pipeline
    scanner = autobump.Scanner(recipe_source,
                               cache_fn=cache and cache + "_scan.pkl",
                               status_fn=recipe_status)

    # Always exclude recipes that were explicitly disabled
    scanner.add(autobump.ExcludeDisabled)

    # Exclude packages that are on the blacklist
    if not ignore_blacklists:
        scanner.add(autobump.ExcludeBlacklisted, recipe_folder, config_dict)

    # Exclude sub-recipes
    if exclude_subrecipes != "never":
        scanner.add(autobump.ExcludeSubrecipe,
                    always=exclude_subrecipes == "always")

    # Exclude recipes with dependencies pending an update
    if not no_check_pending_deps and not no_follow_graph:
        scanner.add(autobump.ExcludeDependencyPending, recipe_source.dag)

    # Load recipe
    git_handler = None
    if check_branch or create_branch or create_pr or only_active:
        # We need to take the recipe from the git repo. This
        # loads the bump/<recipe> branch if available
        git_handler = BiocondaRepo(recipe_folder, dry_run)
        git_handler.checkout_master()
        if only_active:
            scanner.add(autobump.ExcludeNoActiveUpdate, git_handler)
        scanner.add(autobump.GitLoadRecipe, git_handler)

        env_key = os.environ.get("CODE_SIGNING_KEY")
        if sign is None:
            git_handler.enable_signing()
        elif sign:
            git_handler.enable_signing(sign)
        elif env_key:
            try:
                git_handler.enable_signing(install_gpg_key(env_key))
            except ValueError as exc:
                logger.error("Failed to use CODE_SIGNING_KEY from environment: %s",
                             exc)
        if commit_as:
            git_handler.set_user(*commit_as)
    else:
        # Just load from local file system
        scanner.add(autobump.LoadRecipe)
        if sign or sign is None:
            logger.warning("Not using git. --sign has no effect")

    # Exclude recipes that are present in "other channels"
    if exclude_channels != ["none"]:
        if not isinstance(exclude_channels, list):
            exclude_channels = [exclude_channels]
        scanner.add(autobump.ExcludeOtherChannel, exclude_channels,
                    cache and cache + "_repodata.txt")

    # Test if due to pinnings, the package hash would change and a rebuild
    # has become necessary. If so, bump the buildnumber.
    if not no_check_pinnings:
        scanner.add(autobump.CheckPinning, bump_only_python)

    # Check for new versions and update the SHA afterwards
    if not no_check_version_update:
        scanner.add(autobump.UpdateVersion, hosters.Hoster.select_hoster, unparsed_urls)
        if fetch_requirements:
            # This attempts to determine dependencies exported by PyPi packages,
            # requires running setup.py, so only enabled on request.
            scanner.add(autobump.FetchUpstreamDependencies)
        scanner.add(autobump.UpdateChecksums, failed_urls)

    # Write the recipe. For making PRs, the recipe should be written to a branch
    # of its own.
    if create_branch or create_pr:
        scanner.add(autobump.GitWriteRecipe, git_handler)
    else:
        scanner.add(autobump.WriteRecipe)

    # Create a PR for the branch
    if create_pr:
        token = os.environ.get("GITHUB_TOKEN")
        if not token and not dry_run:
            logger.critical("GITHUB_TOKEN required to create PRs")
            exit(1)
        github_handler = githubhandler.AiohttpGitHubHandler(
            token, dry_run, "bioconda", "bioconda-recipes")
        scanner.add(autobump.CreatePullRequest, git_handler, github_handler)

    # Terminate the scanning pipeline after x recipes have reached this point.
    if max_updates:
        scanner.add(autobump.MaxUpdates, max_updates)

    # And go.
    scanner.run()

    # Cleanup
    if git_handler:
        git_handler.close()


@arg('--loglevel', default='info', help='Log level')
def bot(loglevel='info'):
    """Locally accedd bioconda-bot command API

    To run the bot locally, use:

    $ gunicorn bioconda_utils.bot:init_app_internal_celery --worker-class aiohttp.worker.GunicornWebWorker

    You can append --reload to have gunicorn reload if any of the python files change.
    """

    utils.setup_logger('bioconda_utils', loglevel)

    logger.error("Nothing here yet")

def main():
    if '--version' in sys.argv:
        print("This is bioconda-utils version", VERSION)
        sys.exit(0)
    argh.dispatch_commands([
        build, dag, dependent, do_lint, duplicates, update_pinning,
        bioconductor_skeleton, clean_cran_skeleton, autobump, bot
    ])
