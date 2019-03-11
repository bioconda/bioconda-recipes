#!/usr/bin/env python

import sys
import os
import shlex
import logging
from collections import defaultdict, Counter
from functools import partial

import argh
from argh import arg
import networkx as nx
from networkx.drawing.nx_pydot import write_dot
import pandas

from . import utils
from .build import build_recipes
from . import docker_utils
from . import lint_functions
from . import linting
from . import github_integration
from . import bioconductor_skeleton as _bioconductor_skeleton
from . import cran_skeleton
from . import update_pinnings
from . import graph

logger = logging.getLogger(__name__)


def enable_logging(default_loglevel='info'):
    """Adds the parameter ``--loglevel`` and sets up logging

    Args:
      default_loglevel: loglevel used when --loglevel is not passed
    """
    def decorator(func):
        @arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
        @utils.wraps(func)
        def wrapper(*args, loglevel=default_loglevel, **kwargs):
            utils.setup_logger('bioconda_utils', loglevel)
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
                if pdb:
                    import pdb
                    pdb.post_mortem()
                else:
                    raise
        return wrapper
    return decorator


def enable_threads():
    """Adds the paremeter ``--threads`` (or ``-t``) to limit parallelism"""
    def decorator(func):
        @arg('-t', '--threads', help="Limit maximum number of processes used.")
        @utils.wraps(func)
        def wrapper(*args, threads=16, **kwargs):
            utils.set_max_threads(threads)
            func(*args, **kwargs)
        return wrapper
    return decorator


def select_recipes(packages, git_range, recipe_folder, config_filename, config, force):
    if git_range:
        modified = utils.modified_recipes(git_range, recipe_folder, config_filename)
        if not modified:
            logger.info('No recipe modified according to git, exiting.')
            return []

        # Recipes with changed `meta.yaml` or `build.sh` files
        changed_recipes = [
            os.path.dirname(f) for f in modified
            if os.path.basename(f) in ['meta.yaml', 'build.sh'] and
            os.path.exists(f)
        ]
        logger.info(
            'Recipes to consider according to git: \n{}'.format('\n '.join(changed_recipes)))
    else:
        changed_recipes = []

    blacklisted_recipes = utils.get_blacklist(config['blacklists'], recipe_folder)

    selected_recipes = list(utils.get_recipes(recipe_folder, packages))
    _recipes = []
    for recipe in selected_recipes:
        stripped = os.path.relpath(recipe, recipe_folder)
        if stripped in blacklisted_recipes and recipe in changed_recipes:
            logger.warning('%s is blacklisted but also has changed. Consider '
                           'removing from blacklist if you want to build it', recipe)
        if force:
            _recipes.append(recipe)
            logger.debug('forced: %s', recipe)
            continue
        if stripped in blacklisted_recipes:
            logger.debug('blacklisted: %s', recipe)
            continue
        if git_range:
            if recipe not in changed_recipes:
                continue
        _recipes.append(recipe)
        logger.debug(recipe)

    logger.info('Recipes to lint:\n{}'.format('\n '.join(_recipes)))
    return _recipes

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


@arg('recipe_folder', help='Path to top-level dir of recipes.')
@arg('config', help='Path to yaml file specifying the configuration')
@arg(
    '--packages',
    nargs="+",
    help='Glob for package[s] to build. Default is to build all packages. Can '
    'be specified more than once')
@arg('--cache', help='''To speed up debugging, use repodata cached locally in
     the provided filename. If the file does not exist, it will be created the
     first time.''')
@arg('--list-funcs', help='''List the linting functions to be used and then
     exit''')
@arg('--only', nargs='+', help='''Only run this linting function. Can be used
     multiple times.''')
@arg('--exclude', nargs='+', help='''Exclude this linting function. Can be used
     multiple times.''')
@arg('--force', action='store_true', help='''Force linting of packages. If
     specified, --git-range will be ignored and only those packages matching
     --packages globs will be linted.''')
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
@enable_logging()
def lint(recipe_folder, config, packages="*", cache=None, list_funcs=False,
         only=None, exclude=None, force=False, push_status=False, user='bioconda',
         commit=None, push_comment=False, pull_request=None,
         repo='bioconda-recipes', git_range=None, full_report=False):
    """
    Lint recipes

    If --push-status is not set, reports a TSV of linting results to stdout.
    Otherwise pushes a commit status to the specified commit on github.
    """
    if list_funcs:
        print('\n'.join([i.__name__ for i in lint_functions.registry]))
        sys.exit(0)

    if cache is not None:
        utils.RepoData().set_cache(cache)
    registry = lint_functions.registry

    if only is not None:
        registry = list(filter(lambda x: x.__name__ in only, registry))
        if len(registry) == 0:
            sys.stderr.write('No valid linting functions selected, exiting.\n')
            sys.exit(1)

    config_filename = config
    config = utils.load_config(config)

    _recipes = select_recipes(packages, git_range, recipe_folder, config_filename, config, force)

    lint_args = linting.LintArgs(exclude=exclude, registry=registry)
    report = linting.lint(_recipes, lint_args)

    # The returned dataframe is in tidy format; summarize a bit to get a more
    # reasonable log
    if report is not None:
        pandas.set_option('max_colwidth', 500)
        summarized = pandas.DataFrame(
            dict(failed_tests=report.groupby('recipe')['check'].agg('unique')))
        if not full_report:
            logger.error('\n\nThe following recipes failed linting. See '
                         'https://bioconda.github.io/linting.html for details:\n\n%s\n',
                         summarized.to_string())
        else:
            report.to_csv(sys.stdout, sep='\t')

        if push_status:
            github_integration.update_status(
                user, repo, commit, state='error', context='linting',
                description='linting failed, see travis log', target_url=None)
        if push_comment:
            msg = linting.markdown_report(summarized)
            github_integration.push_comment(
                user, repo, pull_request, msg)
        sys.exit(1)

    else:
        if push_status:
            github_integration.update_status(
                user, repo, commit, state='success', context='linting',
                description='linting passed', target_url=None)
        if push_comment:
            msg = linting.markdown_report()
            github_integration.push_comment(
                user, repo, pull_request, msg)


@arg('recipe_folder', help='Path to top-level dir of recipes.')
@arg('config', help='Path to yaml file specifying the configuration')
@arg(
    '--packages',
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
@arg('--keep-image', action='store_true', help='''After building recipes, the
     created Docker image is removed by default to save disk space. Use this
     argument to disable this behavior.''')
@arg('--lint', '--prelint', action='store_true', help='''Just before each recipe, apply
     the linting functions to it. This can be used as an alternative to linting
     all recipes before any building takes place with the `bioconda-utils lint`
     command.''')
@arg('--lint-only', nargs='+',
     help='''Only run this linting function. Can be used multiple times.''')
@arg('--lint-exclude', nargs='+',
     help='''Exclude this linting function. Can be used multiple times.''')
@arg('--check-channels', nargs='+',
     help='''Channels to check recipes against before building. Any recipe
     already present in one of these channels will be skipped. The default is
     the first two channels specified in the config file. Note that this is
     ignored if you specify --git-range.''')
@enable_logging()
def build(
    recipe_folder,
    config,
    packages="*",
    git_range=None,
    testonly=False,
    force=False,
    docker=None,
    mulled_test=False,
    build_script_template=None,
    pkg_dir=None,
    anaconda_upload=False,
    mulled_upload_target=None,
    keep_image=False,
    lint=False,
    lint_only=None,
    lint_exclude=None,
    check_channels=None,
):
    cfg = utils.load_config(config)
    setup = cfg.get('setup', None)
    if setup:
        logger.debug("Running setup: %s" % setup)
        for cmd in setup:
            utils.run(shlex.split(cmd))

    # handle git range
    if git_range and not force:
        modified = utils.modified_recipes(git_range, recipe_folder, config)
        if not modified:
            logger.info('No recipe modified according to git, exiting.')
            exit(0)
        # obtain list of packages to build. `modified` will be a list of *all*
        # files so we need to extract just the package names since
        # build_recipes expects globs

        packages = list(
            set(
                [
                    os.path.dirname(os.path.relpath(f, recipe_folder))
                    for f in modified
                ]
            )
        )
        logger.info('Recipes modified according to git: {}'.format(' '.join(packages)))

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
        )
    else:
        docker_builder = None

    if lint:
        registry = lint_functions.registry
        if lint_only is not None:
            registry = tuple(func for func in registry if func.__name__ in lint_only)
            if len(registry) == 0:
                sys.stderr.write('No valid linting functions selected, exiting.\n')
                sys.exit(1)
        lint_args = linting.LintArgs(exclude=lint_exclude, registry=registry)
    else:
        lint_args = None
        if lint_only is not None:
            logger.warning('--lint-only has no effect unless --lint is specified.')
        if lint_exclude is not None:
            logger.warning('--lint-exclude has no effect unless --lint is specified.')

    label = os.getenv('BIOCONDA_LABEL', None)
    if label == "":
        label = None

    success = build_recipes(
        recipe_folder,
        config=config,
        packages=packages,
        testonly=testonly,
        force=force,
        mulled_test=mulled_test,
        docker_builder=docker_builder,
        anaconda_upload=anaconda_upload,
        mulled_upload_target=mulled_upload_target,
        lint_args=lint_args,
        check_channels=check_channels,
        label=label,
    )
    exit(0 if success else 1)


@arg('recipe_folder', help='Path to recipes directory')
@arg('config', help='Path to yaml file specifying the configuration')
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


@arg('recipe_folder', help='Path to recipes directory')
@arg('config', help='Path to yaml file specifying the configuration')
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
    blacklist = utils.get_blacklist(config.get('blacklists'), recipe_folder)

    all_recipes = utils.get_recipes(recipe_folder, '*')

    from . import recipe
    dag = graph.build_from_recipes(
        recip for recip in recipe.load_parallel_iter(recipe_folder, "*")
        if recip.reldir not in blacklist)

    if packages != "*":
        dag = graph.filter_recipe_dag(dag, packages)

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


@arg('recipe_folder', help='Path to recipes directory')
@arg('config', help='Path to yaml file specifying the configuration')
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
@arg('recipe_folder', help='Path to recipes directory')
@arg('config', help='Path to yaml file specifying the configuration')
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
    Build a Bioconductor recipe. The recipe will be created in the `recipes`
    directory and will be prefixed by "bioconductor-". If `--recursive` is set,
    then any R dependency recipes will be prefixed by "r-".

    These R recipes must be evaluated on a case-by-case basis to determine if
    they are relevant to biology (in which case they should be submitted to
    bioconda) or not (submit to conda-forge).

    Biology-related:
        `bioconda-utils clean-cran-skeleton <recipe> --no-windows`
        and submit to Bioconda.

    Not bio-related:
        `bioconda-utils clean-cran-skeleton <recipe>`
        and submit to conda-forge.

    """
    seen_dependencies = set()

    if package == "update-all-packages":
        if not bioc_version:
            bioc_version = _bioconductor_skeleton.latest_bioconductor_release_version()
        packages = _bioconductor_skeleton.fetchPackages(bioc_version)
        problems = []
        for k, v in packages.items():
            try:
                _bioconductor_skeleton.write_recipe(
                    k, recipe_folder, config, force=True, bioc_version=bioc_version,
                    pkg_version=v['Version'], versioned=versioned, packages=packages,
                    skip_if_in_channels=skip_if_in_channels)
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
    Cleans skeletons created by `conda skeleton cran`.

    Before submitting to conda-forge or Bioconda, recipes generated with `conda
    skeleton cran` need to be cleaned up: comments removed, licenses fixed, and
    other linting.

    Use --no-windows for a Bioconda submission.
    """
    cran_skeleton.clean_skeleton_files(recipe, no_windows=no_windows)


@arg('recipe_folder', help='Path to recipes directory')
@arg('config', help='Path to yaml file specifying the configuration')
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to show in DAG. Default is to show all '
     'packages. Can be specified more than once')
@arg('--exclude-subrecipes', help='''By default, only subrecipes explicitly
     enabled for watch in meta.yaml are considered. Set to 'always' to
     exclude all subrecipes.  Set to 'never' to include all subrecipes''')
@arg('--exclude-channels', nargs="+", help='''Exclude recipes
     building packages present in other channels. Set to 'none' to disable
     check.''')
@arg('--ignore-blacklists', help='''Do not exclude recipes from blacklist''')
@arg('--no-fetch-requirements', help='''Do not try to determine upstream
     requirements''')
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
@arg("--parallel", help='''Maximum number of recipes to consider in parallel''')
@arg("--dry-run", help='''Don't update remote git or github"''')
@enable_logging()
def autobump(recipe_folder, config, packages='*', cache=None,
             failed_urls=None, unparsed_urls=None, recipe_status=None,
             exclude_subrecipes=None, exclude_channels='conda-forge',
             ignore_blacklists=False,
             no_fetch_requirements=False,
             check_branch=False, create_branch=False, create_pr=False,
             only_active=False,
             max_updates=0, parallel=100, dry_run=False):
    """
    Updates recipes in recipe_folder
    """
    # load an register config
    utils.load_config(config)
    from . import update
    from . import githandler
    from . import githubhandler
    from . import hosters
    scanner = update.Scanner(recipe_folder, packages,
                             cache and cache + "_scan.pkl",
                             max_inflight=parallel,
                             status_fn=recipe_status)
    if not ignore_blacklists:
        scanner.add(update.ExcludeBlacklisted, config)
    if exclude_subrecipes != "never":
        scanner.add(update.ExcludeSubrecipe,
                    always=exclude_subrecipes == "always")
    git_handler = None
    if check_branch or create_branch or create_pr or only_active:
        git_handler = githandler.GitHandler(recipe_folder, dry_run)
        if only_active:
            scanner.add(update.ExcludeNoActiveUpdate, git_handler)
        scanner.add(update.GitLoadRecipe, git_handler)
    else:
        scanner.add(update.LoadRecipe)
    if exclude_channels != ["none"]:
        if not isinstance(exclude_channels, list):
            exclude_channels = [exclude_channels]
        scanner.add(update.ExcludeOtherChannel, exclude_channels,
                    cache and cache + "_repodata.txt")

    scanner.add(update.UpdateVersion, hosters.Hoster.select_hoster, unparsed_urls)
    if not no_fetch_requirements:
        scanner.add(update.FetchUpstreamDependencies)
    scanner.add(update.UpdateChecksums, failed_urls)

    if create_branch or create_pr:
        scanner.add(update.GitWriteRecipe, git_handler)
    else:
        scanner.add(update.WriteRecipe)

    if create_pr:
        token = os.environ.get("GITHUB_TOKEN")
        if not token and not dry_run:
            logger.critical("GITHUB_TOKEN required to create PRs")
            exit(1)
        github_handler = githubhandler.AiohttpGitHubHandler(
            token, dry_run, "bioconda", "bioconda-recipes")
        scanner.add(update.CreatePullRequest, git_handler, github_handler)

    if max_updates:
        scanner.add(update.MaxUpdates, max_updates)
    scanner.run()
    if git_handler:
        git_handler.close()


def main():
    argh.dispatch_commands([
        build, dag, dependent, lint, duplicates, update_pinning,
        bioconductor_skeleton, clean_cran_skeleton, autobump
    ])
