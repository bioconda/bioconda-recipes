#!/usr/bin/env python

import sys
import os
import shlex
import logging
from collections import defaultdict

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
from . import pypi

logger = logging.getLogger(__name__)


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
        logger.info('Recipes to consider according to git: \n{}'.format('\n '.join(changed_recipes)))
    else:
        changed_recipes = []

    blacklisted_recipes = utils.get_blacklist(config['blacklists'], recipe_folder)

    selected_recipes = list(utils.get_recipes(recipe_folder, packages))
    _recipes = []
    for recipe in selected_recipes:
        if recipe in blacklisted_recipes and recipe in changed_recipes:
            logger.warning('%s is blacklisted but also has changed. Consider '
                           'removing from blacklist if you want to build it', recipe)
        if force:
            _recipes.append(recipe)
            logger.debug('forced: %s', recipe)
            continue
        if recipe in blacklisted_recipes:
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
def duplicates(
    config,
    strict_version=False,
    strict_build=False,
    dryrun=False,
    remove=False,
    url=False
):
    """
    Detect packages in bioconda that have duplicates in the other defined
    channels.
    """
    config = utils.load_config(config)

    channels = config['channels']
    target_channel = channels[0]

    if strict_version:
        get_spec = lambda pkg: (pkg['name'], pkg['version'])
        if not remove and not url:
            print('name', 'version', 'channels', sep='\t')
    elif strict_build:
        get_spec = lambda pkg: (pkg['name'], pkg['version'], pkg['build'])
        if not remove and not url:
            print('name', 'version', 'build', 'channels', sep='\t')
    else:
        get_spec = lambda pkg: pkg['name']
        if not remove and not url:
            print('name', 'channels', sep='\t')

    def remove_package(spec):
        if not strict_build:
            raise ValueError('Removing packages is only supported in case of '
                             '--strict-build.')
        fn = '{}-{}-{}.tar.bz2'.format(*spec)
        name, version = spec[:2]
        subcmd = [
            'remove', '-f',
            '{channel}/{name}/{version}/{fn}'.format(
                name=name, version=version, fn=fn, channel=target_channel
            )
        ]
        if dryrun:
            print(utils.bin_for('anaconda'), *subcmd)
        else:
            token = os.environ.get('ANACONDA_TOKEN')
            if token is None:
                token = []
            else:
                token = ['-t', token]
            print(utils.run([utils.bin_for('anaconda')] + token + subcmd, mask=[token]).stdout)

    def get_packages(channel):
        return {get_spec(pkg)
                for repodata in utils.get_channel_repodata(channel)
                for pkg in repodata['packages'].values()}

    # packages in our channel
    packages = get_packages(target_channel)

    # packages in channels we depend on
    common = defaultdict(list)
    for channel in channels[1:]:
        pkgs = get_packages(channel)
        for pkg in packages & pkgs:
            common[pkg].append(channel)

    for pkg, _channels in sorted(common.items()):
        if remove:
            remove_package(pkg)
        else:
            if url:
                if not strict_version and not strict_build:
                    print('https://anaconda.org/{}/{}'.format(
                          target_channel, pkg[0]))
                print('https://anaconda.org/{}/{}/files?version={}'.format(
                    target_channel, *pkg))
            else:
                print(*pkg, *_channels, sep='\t')


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
@arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
def lint(recipe_folder, config, packages="*", cache=None, list_funcs=False,
         only=None, exclude=None, force=False, push_status=False, user='bioconda',
         commit=None, push_comment=False, pull_request=None,
         repo='bioconda-recipes', git_range=None, full_report=False,
         loglevel='info'):
    """
    Lint recipes

    If --push-status is not set, reports a TSV of linting results to stdout.
    Otherwise pushes a commit status to the specified commit on github.
    """
    utils.setup_logger('bioconda_utils', loglevel)

    if list_funcs:
        print('\n'.join([i.__name__ for i in lint_functions.registry]))
        sys.exit(0)

    df = linting.channel_dataframe(cache=cache)
    registry = lint_functions.registry

    if only is not None:
        registry = list(filter(lambda x: x.__name__ in only, registry))
        if len(registry) == 0:
            sys.stderr.write('No valid linting functions selected, exiting.\n')
            sys.exit(1)

    config_filename = config
    config = utils.load_config(config)

    _recipes = select_recipes(packages, git_range, recipe_folder, config_filename, config, force)

    report = linting.lint(
        _recipes,
        config=config,
        df=df,
        exclude=exclude,
        registry=registry,
    )

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
@arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
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
def build(
    recipe_folder,
    config,
    packages="*",
    git_range=None,
    testonly=False,
    force=False,
    docker=None,
    loglevel="info",
    mulled_test=False,
    build_script_template=None,
    pkg_dir=None,
    anaconda_upload=False,
    mulled_upload_target=None,
    keep_image=False,
):
    utils.setup_logger('bioconda_utils', loglevel)

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
def dag(recipe_folder, config, packages="*", format='gml', hide_singletons=False):
    """
    Export the DAG of packages to a graph format file for visualization
    """
    dag, name2recipes = utils.get_dag(utils.get_recipes(recipe_folder, packages), config)
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
@arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
def dependent(recipe_folder, config, restrict=False, dependencies=None, reverse_dependencies=None, loglevel='warning'):
    """
    Print recipes dependent on a package
    """
    if dependencies and reverse_dependencies:
        raise ValueError(
            '`dependencies` and `reverse_dependencies` are mutually exclusive')

    utils.setup_logger('bioconda_utils', loglevel)

    d, n2r = utils.get_dag(utils.get_recipes(recipe_folder, "*"), config, restrict=restrict)

    if reverse_dependencies is not None:
        func, packages = nx.algorithms.descendants, reverse_dependencies
    elif dependencies is not None:
        func, packages = nx.algorithms.ancestors, dependencies

    pkgs = []
    for pkg in packages:
        pkgs.extend(list(func(d, pkg)))
    print('\n'.join(sorted(pkgs)))


@arg('package', help='''Bioconductor package name. This is case-sensitive, and
     must match the package name on the Bioconductor site.''')
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
@arg('--loglevel',  help='Log level')
@arg('--recursive', action='store_true', help="""Creates the recipes for all
     Bioconductor and CRAN dependencies of the specified package.""")
@arg('--skip-if-in-channels', nargs='*', help="""When --recursive is used, it will build
     *all* recipes. Use this argument to skip recursive building for packages
     that already exist in the packages listed here.""")
def bioconductor_skeleton(
    recipe_folder, config, package, versioned=False, force=False,
    pkg_version=None, bioc_version=None, loglevel='debug', recursive=False,
    skip_if_in_channels=['conda-forge', 'bioconda'],
):
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
    utils.setup_logger('bioconda_utils', loglevel)
    seen_dependencies = set()

    written = _bioconductor_skeleton.write_recipe(
        package, recipe_folder, config, force=force, bioc_version=bioc_version,
        pkg_version=pkg_version, versioned=versioned, recursive=recursive,
        seen_dependencies=seen_dependencies,
        skip_if_in_channels=skip_if_in_channels)

    # E.g., r-probmetab has versioned 1.0 and 1.1 dirs in bioconda-recipes, and
    # this fails to find the meta.yaml files.
    # if recursive:
    #     for package in os.listdir(recipe_folder):
    #         if package[:2] == "r-":
    #             cran_skeleton.clean_skeleton_files(os.path.join(recipe_folder, package))


@arg('recipe', help='''Path to recipe to be cleaned''')
@arg('--no-windows', action='store_true', help="""Use this when submitting an
     R package to Bioconda. After a CRAN skeleton is created, any
     Windows-related lines will be removed and the bld.bat file will be
     removed.""")
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
@arg('--loglevel', default='debug', help='Log level')
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to show in DAG. Default is to show all '
     'packages. Can be specified more than once')
@arg('--only-out-of-date', help='Only report results for packages that need an update')
def pypi_check(recipe_folder, config, loglevel='info', packages='*', only_out_of_date=False):
    """
    Checks recipes to see if an updated version is available on PyPI.

    Recipes are only checked if "pypi" is somewhere in the source URL of their
    meta.yaml.

    A TSV is reported to stdout, with columns:
        name:
            package name

        bioconda_version:
            latest existing recipe version

        pypi_version:
            latest version on PyPI. If None, a PyPI package could not be found.

        needs_update:
            True if PyPI version is later than bioconda_version

        conda_forge_version:
            latest version in the conda-forge channel. "None" if not available
            in conda-forge.

        action:
            One of the following:
                - unavailable (not found on PyPI, check name)
                - up-to-date (no action needed)
                - update-bioconda (simply need to re-run conda skeleton)
                - remove-from-bioconda (conda-forge has later version)
                - decide-where-to-update (both conda-forge and bioconda are out-of-date)
    """
    utils.setup_logger('bioconda_utils', loglevel)
    for result in pypi.check_all(recipe_folder, config):
        if only_out_of_date:
            if not result[3]:
                continue
        print('\t'.join(map(str, result)))


def main():
    argh.dispatch_commands([build, dag, dependent, lint, duplicates, bioconductor_skeleton, pypi_check, clean_cran_skeleton])
