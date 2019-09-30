"""
Package Builder
"""

import subprocess as sp
from collections import defaultdict, namedtuple
import os
import logging

from typing import List

# TODO: UnsatisfiableError is not yet in exports for conda 4.5.4
# from conda.exports import UnsatisfiableError
from conda.exceptions import UnsatisfiableError
import networkx as nx
import pandas

from . import utils
from . import docker_utils
from . import pkg_test
from . import upload
from . import lint
from . import graph

logger = logging.getLogger(__name__)


#: Result tuple for builds comprising success status and list of docker images
BuildResult = namedtuple("BuildResult", ["success", "mulled_images"])


def conda_build_purge() -> None:
    """Calls conda build purge and optionally conda clean

    ``conda clean --all`` is called if we haveless than 300 MB free space
    on the current disk.
    """
    utils.run(["conda", "build", "purge"], mask=False)

    free_mb = utils.get_free_space()
    if free_mb < 300:
        logger.info("CLEANING UP PACKAGE CACHE (free space: %iMB).", free_mb)
        utils.run(["conda", "clean", "--all"], mask=False)
        logger.info("CLEANED UP PACKAGE CACHE (free space: %iMB).",
                    utils.get_free_space())


def has_conda_in_build(recipe):
    """Checks if recipe has conda or conda build in deps"""
    deps = utils.get_deps(recipe, build=True)
    deps.update(utils.get_deps(recipe, build=False))
    return any(pkg in deps for pkg in ('conda', 'conda-build'))


def build(recipe: str, pkg_paths: List[str] = None,
          testonly: bool = False, mulled_test: bool = True,
          channels: List[str] = None,
          docker_builder: docker_utils.RecipeBuilder = None,
          raise_error: bool = False,
          linter=None) -> BuildResult:
    """
    Build a single recipe for a single env

    Arguments:
      recipe: Path to recipe
      pkg_paths: List of paths to expected packages
      testonly: Only run the tests described in the meta.yaml
      mulled_test: Run tests in minimal docker container
      channels: Channels to include via the ``--channel`` argument to
        conda-build. Higher priority channels should come first.
      docker_builder : docker_utils.RecipeBuilder object
        Use this docker builder to build the recipe, copying over the built
        recipe to the host's conda-bld directory.
      raise_error: Instead of returning a failed build result, raise the
        error instead. Used for testing.
      linter: Linter to use for checking recipes
    """
    if linter:
        logger.info('Linting recipe %s', recipe)
        linter.clear_messages()
        if linter.lint([recipe]):
            logger.error('\n\nThe recipe %s failed linting. See '
                         'https://bioconda.github.io/linting.html for details:\n\n%s\n',
                         recipe, linter.get_report())
            return BuildResult(False, None)
        logger.info("Lint checks passed")

    # Copy env allowing only whitelisted vars
    whitelisted_env = {
        k: str(v)
        for k, v in os.environ.items()
        if utils.allowed_env_var(k, docker_builder is not None)
    }

    logger.info("BUILD START %s", recipe)

    args = ['--override-channels']
    if testonly:
        args += ["--test"]
    else:
        args += ["--no-anaconda-upload"]

    for channel in channels or ['local']:
        args += ['-c', channel]

    logger.debug('Build and Channel Args: %s', args)

    # Even though there may be variants of the recipe that will be built, we
    # will only be checking attributes that are independent of variants (pkg
    # name, version, noarch, whether or not an extended container was used)
    meta = utils.load_first_metadata(recipe, finalize=False)
    is_noarch = bool(meta.get_value('build/noarch', default=False))
    use_base_image = meta.get_value('extra/container', {}).get('extended-base', False)
    base_image = 'bioconda/extended-base-image' if use_base_image else None

    try:
        if docker_builder is not None:
            docker_builder.build_recipe(recipe_dir=os.path.abspath(recipe),
                                        build_args=' '.join(args),
                                        env=whitelisted_env,
                                        noarch=is_noarch)
            # Use presence of expected packages to check for success
            for pkg_path in pkg_paths:
                if not os.path.exists(pkg_path):
                    logger.error(
                        "BUILD FAILED: the built package %s "
                        "cannot be found", pkg_path)
                    return BuildResult(False, None)
        else:
            conda_build_cmd = [utils.bin_for('conda'), 'build']
            # - Temporarily reset os.environ to avoid leaking env vars
            # - Also pass filtered env to run()
            # - Point conda-build to meta.yaml, to avoid building subdirs
            with utils.sandboxed_env(whitelisted_env):
                cmd = conda_build_cmd + args
                for config_file in utils.get_conda_build_config_files():
                    cmd += [config_file.arg, config_file.path]
                cmd += [os.path.join(recipe, 'meta.yaml')]
                with utils.Progress():
                    utils.run(cmd, env=os.environ, mask=False)

        logger.info('BUILD SUCCESS %s',
                    ' '.join(os.path.basename(p) for p in pkg_paths))

    except (docker_utils.DockerCalledProcessError, sp.CalledProcessError) as exc:
        logger.error('BUILD FAILED %s', recipe)
        if raise_error:
            raise exc
        return BuildResult(False, None)

    if mulled_test:
        logger.info('TEST START via mulled-build %s', recipe)
        mulled_images = []
        for pkg_path in pkg_paths:
            try:
                pkg_test.test_package(pkg_path, base_image=base_image)
            except sp.CalledProcessError:
                logger.error('TEST FAILED: %s', recipe)
                return BuildResult(False, None)
            logger.info("TEST SUCCESS %s", recipe)
            mulled_images.append(pkg_test.get_image_name(pkg_path))
        return BuildResult(True, mulled_images)

    return BuildResult(True, None)


def remove_cycles(dag, name2recipes, failed, skip_dependent):
    nodes_in_cycles = set()
    for cycle in list(nx.simple_cycles(dag)):
        logger.error('BUILD ERROR: dependency cycle found: %s', cycle)
        nodes_in_cycles.update(cycle)

    for name in sorted(nodes_in_cycles):
        cycle_fail_recipes = sorted(name2recipes[name])
        logger.error('BUILD ERROR: cannot build recipes for %s since '
                     'it cyclically depends on other packages in the '
                     'current build job. Failed recipes: %s',
                     name, cycle_fail_recipes)
        failed.extend(cycle_fail_recipes)
        for node in nx.algorithms.descendants(dag, name):
            if node not in nodes_in_cycles:
                skip_dependent[node].extend(cycle_fail_recipes)
    return dag.subgraph(name for name in dag if name not in nodes_in_cycles)


def get_subdags(dag, testonly):
    subdags_n = int(os.environ.get("SUBDAGS", 1))
    subdag_i = int(os.environ.get("SUBDAG", 0))
    if subdag_i >= subdags_n:
        raise ValueError(
            "SUBDAG=%s (zero-based) but only SUBDAGS=%s "
            "subdags are available")

    # Get connected subdags and sort by nodes
    if testonly:
        # use each node as a subdag (they are grouped into equal sizes below)
        node_lists = sorted([[n] for n in nx.nodes(dag)])
    else:
        node_lists = [list(nodes) for nodes in nx.connected_components(dag.to_undirected())]

    # chunk subdags such that we have at most subdags_n many
    if subdags_n < len(node_lists):
        chunks = [[node for nodes in node_lists[i::subdags_n] for node in nodes]
                  for i in range(subdags_n)]
    else:
        chunks = node_lists

    if subdag_i >= len(chunks):
        return dag.subgraph([])

    subdag = dag.subgraph(chunks[subdag_i])
    logger.info("Building and testing subdag %s of %s", subdag_i + 1, subdags_n)
    return subdag


def build_recipes(recipe_folder: str, config_path: str, recipes: List[str],
                  mulled_test: bool = True, testonly: bool = False,
                  force: bool = False,
                  docker_builder: docker_utils.RecipeBuilder = None,
                  label: str = None,
                  anaconda_upload: bool = False,
                  mulled_upload_target=None,
                  check_channels: List[str] = None,
                  do_lint: bool = None,
                  lint_exclude: List[str] = None,
                  keep_old_work: bool = False):
    """
    Build one or many bioconda packages.

    Arguments:
      recipe_folder: Directory containing possibly many, and possibly nested, recipes.
      config_path: Path to config file
      packages: Glob indicating which packages should be considered. Note that packages
        matching the glob will still be filtered out by any blacklists
        specified in the config.
      mulled_test: If true, test the package in a minimal container.
      testonly: If true, only run test.
      force: If true, build the recipe even though it would otherwise be filtered out.
      docker_builder: If specified, use to build all recipes
      label: If specified, use to label uploaded packages on anaconda. Default is "main" label.
      anaconda_upload: If true, upload the package(s) to anaconda.org.
      mulled_upload_target: If specified, upload the mulled docker image to the given target
        on quay.io.
      check_channels: Channels to check to see if packages already exist in them.
        Fefaults to every channel in the config file except "defaults".
      do_lint: Whether to run linter
      lint_exclude: List of linting functions to exclude.
      keep_old_work: Do not remove anything from environment, even after successful build and test.
    """
    if not recipes:
        logger.info("Nothing to be done.")
        return True

    config = utils.load_config(config_path)
    blacklist = utils.get_blacklist(config, recipe_folder)

    # get channels to check
    if check_channels is None:
        if config['channels']:
            check_channels = [c for c in config['channels'] if c != "defaults"]
        else:
            check_channels = []

    # setup linting
    if do_lint:
        always_exclude = ('build_number_needs_bump',)
        if not lint_exclude:
            lint_exclude = always_exclude
        else:
            lint_exclude = tuple(set(lint_exclude) | set(always_exclude))
        linter = lint.Linter(config, recipe_folder, lint_exclude)
    else:
        linter = None

    failed = []

    dag, name2recipes = graph.build(recipes, config=config_path, blacklist=blacklist)
    if not dag:
        logger.info("Nothing to be done.")
        return True

    logger.info("Building and testing %s recipes in total", len(dag))
    logger.info("Recipes to build: \n%s", "\n".join(dag.nodes()))

    skip_dependent = defaultdict(list)
    subdag = get_subdags(dag, testonly)
    subdag = remove_cycles(subdag, name2recipes, failed, skip_dependent)
    if not subdag:
        logger.info("Nothing to be done.")
        return True

    recipe2name = {}
    for name, recipe_list in name2recipes.items():
        for recipe in recipe_list:
            recipe2name[recipe] = name

    recipes = [(recipe, recipe2name[recipe])
               for package in nx.topological_sort(subdag)
               for recipe in name2recipes[package]]


    built_recipes = []
    skipped_recipes = []
    failed_uploads = []

    for recipe, name in recipes:
        if name in skip_dependent:
            logger.info('BUILD SKIP: skipping %s because it depends on %s '
                        'which had a failed build.',
                        recipe, skip_dependent[name])
            skipped_recipes.append(recipe)
            continue

        logger.info('Determining expected packages for %s', recipe)
        try:
            pkg_paths = utils.get_package_paths(recipe, check_channels, force=force)
        except utils.DivergentBuildsError as exc:
            logger.error('BUILD ERROR: packages with divergent build strings in repository '
                         'for recipe %s. A build number bump is likely needed: %s',
                         recipe, exc)
            failed.append(recipe)
            for pkg in nx.algorithms.descendants(subdag, name):
                skip_dependent[pkg].append(recipe)
            continue
        except UnsatisfiableError as exc:
            logger.error('BUILD ERROR: could not determine dependencies for recipe %s: %s',
                         recipe, exc)
            failed.append(recipe)
            for pkg in nx.algorithms.descendants(subdag, name):
                skip_dependent[pkg].append(recipe)
            continue
        if not pkg_paths:
            logger.info("Nothing to be done for recipe %s", recipe)
            continue

        # If a recipe depends on conda, it means it must be installed in
        # the root env, which is not compatible with mulled-build tests. In
        # that case, we temporarily disable the mulled-build tests for the
        # recipe.
        keep_mulled_test = not has_conda_in_build(recipe)
        if mulled_test and not keep_mulled_test:
            logger.info('TEST SKIP: skipping mulled-build test for %s because it '
                        'depends on conda or conda-build', recipe)

        res = build(recipe=recipe,
                    pkg_paths=pkg_paths,
                    testonly=testonly,
                    mulled_test=mulled_test and keep_mulled_test,
                    channels=config['channels'],
                    docker_builder=docker_builder,
                    linter=linter)

        if not res.success:
            failed.append(recipe)
            for pkg in nx.algorithms.descendants(subdag, name):
                skip_dependent[pkg].append(recipe)
        else:
            built_recipes.append(recipe)
            if not testonly:
                if anaconda_upload:
                    for pkg in pkg_paths:
                        if not upload.anaconda_upload(pkg, label=label):
                            failed_uploads.append(pkg)
                if mulled_upload_target and keep_mulled_test:
                    for img in res.mulled_images:
                        upload.mulled_upload(img, mulled_upload_target)

        # remove traces of the build
        if not keep_old_work:
            conda_build_purge()

    if failed or failed_uploads:
        logger.error('BUILD SUMMARY: of %s recipes, '
                     '%s failed and %s were skipped. '
                     'Details of recipes and environments follow.',
                     len(recipes), len(failed), len(skipped_recipes))
        if built_recipes:
            logger.error('BUILD SUMMARY: while the entire build failed, '
                         'the following recipes were built successfully:\n%s',
                         '\n'.join(built_recipes))
        for recipe in failed:
            logger.error('BUILD SUMMARY: FAILED recipe %s', recipe)
        for name, dep in skip_dependent.items():
            logger.error('BUILD SUMMARY: SKIPPED recipe %s '
                         'due to failed dependencies %s', name, dep)
        if failed_uploads:
            logger.error('UPLOAD SUMMARY: the following packages failed to upload:\n%s',
                         '\n'.join(failed_uploads))
        return False

    logger.info("BUILD SUMMARY: successfully built %s of %s recipes",
                len(built_recipes), len(recipes))
    return True
