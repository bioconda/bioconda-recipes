import subprocess as sp
from itertools import chain
from collections import defaultdict, namedtuple
import os
import logging

# TODO: UnsatisfiableError is not yet in exports for conda 4.5.4
# from conda.exports import UnsatisfiableError
from conda.exceptions import UnsatisfiableError
import networkx as nx
import pandas

from . import utils
from . import docker_utils
from . import pkg_test
from . import upload
from . import linting

logger = logging.getLogger(__name__)


BuildResult = namedtuple("BuildResult", ["success", "mulled_images"])


def purge():
    utils.run(["conda", "build", "purge"], mask=False)

    free = utils.get_free_space()
    if free < 10:
        logger.info("CLEANING UP PACKAGE CACHE (free space: %iMB).", free)
        utils.run(["conda", "clean", "--all"], mask=False)
        logger.info("CLEANED UP PACKAGE CACHE (free space: %iMB).",
                    utils.get_free_space())


def build(
    recipe,
    recipe_folder,
    pkg_paths=None,
    testonly=False,
    mulled_test=True,
    force=False,
    channels=None,
    docker_builder=None,
    _raise_error=False,
    lint_args=None,
):
    """
    Build a single recipe for a single env

    Parameters
    ----------
    recipe : str
        Path to recipe

    pkgs : list
        List of packages to build

    testonly : bool
        If True, skip building and instead run the test described in the
        meta.yaml.

    mulled_test : bool
        Test the built package in a minimal docker container

    force : bool
        If True, the recipe will be built even if it already exists. Note that
        typically you'd want to bump the build number rather than force
        a build.

    channels : list
        Channels to include via the `--channel` argument to conda-build. Higher
        priority channels should come first.

    docker_builder : docker_utils.RecipeBuilder object
        Use this docker builder to build the recipe, copying over the built
        recipe to the host's conda-bld directory.

    _raise_error : bool
        Instead of returning a failed build result, raise the error instead.
        Used for testing.

    lint_args : linting.LintArgs | None
        If not None, then apply linting just before building.
    """

    if lint_args is not None:
        logger.info('Linting recipe')
        report = linting.lint([recipe], lint_args)
        if report is not None:
            summarized = pandas.DataFrame(
                dict(failed_tests=report.groupby('recipe')['check'].agg('unique')))
            logger.error('\n\nThe following recipes failed linting. See '
                         'https://bioconda.github.io/linting.html for details:\n\n%s\n',
                         summarized.to_string())
            return BuildResult(False, None)

    # Clean provided env and exisiting os.environ to only allow whitelisted env
    # vars
    _docker = docker_builder is not None

    whitelisted_env = {}
    whitelisted_env.update({k: str(v)
                            for k, v in os.environ.items()
                            if utils.allowed_env_var(k, _docker)})

    logger.info("BUILD START %s", recipe)

    # --no-build-id is needed for some very long package names that triggers
    # the 89 character limits this option can be removed as soon as all
    # packages are rebuild with the 255 character limit
    # Moreover, --no-build-id will block us from using parallel builds in
    # conda-build 2.x build_args = ["--no-build-id"]

    # use global variant config file (contains pinnings)
    build_args = ["--skip-existing"]
    build_args = []
    if testonly:
        build_args.append("--test")
    else:
        build_args += ["--no-anaconda-upload"]

    channel_args = []
    if channels:
        for c in channels:
            channel_args += ['--channel', c]

    logger.debug('build_args: %s', build_args)
    logger.debug('channel_args: %s', channel_args)

    CONDA_BUILD_CMD = [utils.bin_for('conda'), 'build']

    # Even though there may be variants of the recipe that will be built, we
    # will only be checking attributes that are independent of variants (pkg
    # name, version, noarch, whether or not an extended container was used)
    meta = utils.load_first_metadata(recipe)

    try:
        # Note we're not sending the contents of os.environ here. But we do
        # want to add TRAVIS* vars if that behavior is not disabled.
        if docker_builder is not None:

            docker_builder.build_recipe(
                recipe_dir=os.path.abspath(recipe),
                build_args=' '.join(channel_args + build_args),
                env=whitelisted_env,
                noarch=bool(meta.get_value('build/noarch', default=False))
            )

            for pkg_path in pkg_paths:
                if not os.path.exists(pkg_path):
                    logger.error(
                        "BUILD FAILED: the built package %s "
                        "cannot be found", pkg_path)
                    return BuildResult(False, None)
        else:

            # Temporarily reset os.environ to avoid leaking env vars to
            # conda-build, and explicitly provide `env` to `run()`
            # we explicitly point to the meta.yaml, in order to keep
            # conda-build from building all subdirectories
            with utils.sandboxed_env(whitelisted_env):
                cmd = CONDA_BUILD_CMD + build_args + channel_args
                for config_file in utils.get_conda_build_config_files():
                    cmd.extend([config_file.arg, config_file.path])
                cmd += [os.path.join(recipe, 'meta.yaml')]
                logger.debug('command: %s', cmd)
                with utils.Progress():
                    utils.run(cmd, env=os.environ, mask=False)

        logger.info('BUILD SUCCESS %s',
                    ' '.join(os.path.basename(p) for p in pkg_paths))

    except (docker_utils.DockerCalledProcessError, sp.CalledProcessError) as e:
            logger.error('BUILD FAILED %s', recipe)
            if _raise_error:
                raise e
            return BuildResult(False, None)

    if not mulled_test:
        return BuildResult(True, None)

    logger.info('TEST START via mulled-build %s', recipe)

    use_base_image = meta.get_value('extra/container', {}).get('extended-base', False)
    base_image = 'bioconda/extended-base-image' if use_base_image else None

    mulled_images = []
    for pkg_path in pkg_paths:
        try:
            pkg_test.test_package(pkg_path, base_image=base_image)
        except sp.CalledProcessError as e:
            logger.error('TEST FAILED: %s', recipe)
            return BuildResult(False, None)
        else:
            logger.info("TEST SUCCESS %s", recipe)
            mulled_images.append(pkg_test.get_image_name(pkg_path))
    return BuildResult(True, mulled_images)


def build_recipes(
    recipe_folder,
    config,
    packages="*",
    mulled_test=True,
    testonly=False,
    force=False,
    docker_builder=None,
    label=None,
    anaconda_upload=False,
    mulled_upload_target=None,
    check_channels=None,
    lint_args=None,
):
    """
    Build one or many bioconda packages.

    Parameters
    ----------

    recipe_folder : str
        Directory containing possibly many, and possibly nested, recipes.

    config : str or dict
        If string, path to config file; if dict then assume it's an
        already-parsed config file.

    packages : str
        Glob indicating which packages should be considered. Note that packages
        matching the glob will still be filtered out by any blacklists
        specified in the config.

    mulled_test : bool
        If True, then test the package in a minimal container.

    testonly : bool
        If True, only run test.

    force : bool
        If True, build the recipe even though it would otherwise be filtered
        out.

    docker_builder : docker_utils.RecipeBuilder instance
        If not None, then use this RecipeBuilder to build all recipes.

    label : str
        Optional label to use when uploading packages. Useful for testing and
        debugging. Default is to use the "main" label.

    anaconda_upload :  bool
        If True, upload the package to anaconda.org.

    mulled_upload_target : None
        If not None, upload the mulled docker image to the given target on quay.io.

    check_channels : list
        Channels to check to see if packages already exist in them. If None,
        then defaults to the highest-priority channel (that is,
        `config['channels'][0]`). If this list is empty, then do not check any
        channels.

    lint_args : linting.LintArgs | None
        If not None, then apply linting just before building.
    """
    orig_config = config
    config = utils.load_config(config)
    blacklist = utils.get_blacklist(config['blacklists'], recipe_folder)

    if check_channels is None:
        if config['channels']:
            check_channels = [config['channels'][0]]
        else:
            check_channels = []

    logger.info('blacklist: %s', ', '.join(sorted(blacklist)))

    if packages == "*":
        packages = ["*"]
    recipes = []
    for package in packages:
        for recipe in utils.get_recipes(recipe_folder, package):
            if os.path.relpath(recipe, recipe_folder) in blacklist:
                logger.debug('blacklisted: %s', recipe)
                continue
            recipes.append(recipe)
            logger.debug(recipe)
    if not recipes:
        logger.info("Nothing to be done.")
        return True

    logger.debug('recipes: %s', recipes)

    if lint_args is not None:
        df = lint_args.df
        if df is None:
            logger.info("Downloading channel information to use for linting")
            df = linting.channel_dataframe(channels=['conda-forge', 'defaults'])
        lint_exclude = (lint_args.exclude or ())
        if 'already_in_bioconda' not in lint_exclude:
            lint_exclude = tuple(lint_exclude) + ('already_in_bioconda',)
        lint_args = linting.LintArgs(df, lint_exclude, lint_args.registry)

    dag, name2recipes = utils.get_dag(recipes, config=orig_config, blacklist=blacklist)
    recipe2name = {}
    for k, v in name2recipes.items():
        for i in v:
            recipe2name[i] = k

    if not dag:
        logger.info("Nothing to be done.")
        return True
    else:
        logger.info("Building and testing %s recipes in total", len(dag))
        logger.info("Recipes to build: \n%s", "\n".join(dag.nodes()))

    subdags_n = int(os.environ.get("SUBDAGS", 1))
    subdag_i = int(os.environ.get("SUBDAG", 0))

    if subdag_i >= subdags_n:
        raise ValueError(
            "SUBDAG=%s (zero-based) but only SUBDAGS=%s "
            "subdags are available")

    failed = []
    skip_dependent = defaultdict(list)

    # Get connected subdags and sort by nodes
    if testonly:
        # use each node as a subdag (they are grouped into equal sizes below)
        subdags = sorted([[n] for n in nx.nodes(dag)])
    else:
        # take connected components as subdags, remove cycles
        subdags = []
        for cc_nodes in nx.connected_components(dag.to_undirected()):
            cc = dag.subgraph(sorted(cc_nodes))
            nodes_in_cycles = set()
            for cycle in list(nx.simple_cycles(cc)):
                logger.error(
                    'BUILD ERROR: '
                    'dependency cycle found: %s',
                    cycle,
                )
                nodes_in_cycles.update(cycle)
            for name in sorted(nodes_in_cycles):
                cycle_fail_recipes = sorted(name2recipes[name])
                logger.error(
                    'BUILD ERROR: '
                    'cannot build recipes for %s since it cyclically depends '
                    'on other packages in the current build job. Failed '
                    'recipes: %s',
                    name, cycle_fail_recipes,
                )
                failed.extend(cycle_fail_recipes)
                for n in nx.algorithms.descendants(cc, name):
                    if n in nodes_in_cycles:
                        continue  # don't count packages twice (failed/skipped)
                    skip_dependent[n].extend(cycle_fail_recipes)
            cc_without_cycles = dag.subgraph(
                name for name in cc if name not in nodes_in_cycles
            )
            # ensure that packages which need a build are built in the right order
            subdags.append(nx.topological_sort(cc_without_cycles))
    # chunk subdags such that we have at most subdags_n many
    if subdags_n < len(subdags):
        chunks = [[n for subdag in subdags[i::subdags_n] for n in subdag]
                  for i in range(subdags_n)]
    else:
        chunks = subdags
    if subdag_i >= len(chunks):
        logger.info("Nothing to be done.")
        return True
    # merge subdags of the selected chunk
    subdag = dag.subgraph(chunks[subdag_i])


    recipes = [recipe
               for package in subdag
               for recipe in name2recipes[package]]

    logger.info(
        "Building and testing subdag %s of %s (%s recipes)",
        subdag_i + 1, subdags_n, len(recipes)
    )

    built_recipes = []
    skipped_recipes = []
    all_success = True
    failed_uploads = []
    channel_packages = utils.get_all_channel_packages(check_channels)

    for recipe in recipes:
        recipe_success = True
        name = recipe2name[recipe]

        if name in skip_dependent:
            logger.info(
                'BUILD SKIP: '
                'skipping %s because it depends on %s '
                'which had a failed build.',
                recipe, skip_dependent[name])
            skipped_recipes.append(recipe)
            continue

        logger.info('Determining expected packages')
        try:
            pkg_paths = utils.get_package_paths(recipe, channel_packages,
                                                force=force)
        except utils.DivergentBuildsError as e:
            logger.error(
                'BUILD ERROR: '
                'packages with divergent build strings in repository '
                'for recipe %s. A build number bump is likely needed: %s',
                recipe, e)
            failed.append(recipe)
            for n in nx.algorithms.descendants(subdag, name):
                skip_dependent[n].append(recipe)
            continue
        except UnsatisfiableError as e:
            logger.error(
                'BUILD ERROR: '
                'could not determine dependencies for recipe %s: %s',
                recipe, e)
            failed.append(recipe)
            for n in nx.algorithms.descendants(subdag, name):
                skip_dependent[n].append(recipe)
            continue
        if not pkg_paths:
            logger.info("Nothing to be done for recipe %s", recipe)
            continue

        # If a recipe depends on conda, it means it must be installed in
        # the root env, which is not compatible with mulled-build tests. In
        # that case, we temporarily disable the mulled-build tests for the
        # recipe.
        deps = []
        deps += utils.get_deps(recipe, orig_config, build=True)
        deps += utils.get_deps(recipe, orig_config, build=False)
        keep_mulled_test = True
        if 'conda' in deps or 'conda-build' in deps:
            keep_mulled_test = False
            if mulled_test:
                logger.info(
                    'TEST SKIP: '
                    'skipping mulled-build test for %s because it '
                    'depends on conda or conda-build', recipe)

        res = build(
            recipe=recipe,
            recipe_folder=recipe_folder,
            pkg_paths=pkg_paths,
            testonly=testonly,
            mulled_test=mulled_test and keep_mulled_test,
            force=force,
            channels=config['channels'],
            docker_builder=docker_builder,
            lint_args=lint_args,
        )

        all_success &= res.success
        recipe_success &= res.success

        if not res.success:
            failed.append(recipe)
            for n in nx.algorithms.descendants(subdag, name):
                skip_dependent[n].append(recipe)
        elif not testonly:
            for pkg in pkg_paths:
                # upload build
                if anaconda_upload:
                    if not upload.anaconda_upload(pkg, label):
                        failed_uploads.append(pkg)
            if mulled_upload_target and keep_mulled_test:
                for img in res.mulled_images:
                    upload.mulled_upload(img, mulled_upload_target)

        # remove traces of the build
        purge()

        if recipe_success:
            built_recipes.append(recipe)

    if failed or failed_uploads:
        logger.error(
            'BUILD SUMMARY: of %s recipes, '
            '%s failed and %s were skipped. '
            'Details of recipes and environments follow.',
            len(recipes), len(failed), len(skipped_recipes))

        if len(built_recipes) > 0:
            logger.error(
                'BUILD SUMMARY: while the entire build failed, '
                'the following recipes were built successfully:\n%s',
                '\n'.join(built_recipes))

        for recipe in failed:
            logger.error(
                'BUILD SUMMARY: FAILED recipe %s', recipe)

        for name, dep in skip_dependent.items():
            logger.error(
                'BUILD SUMMARY: SKIPPED recipe %s '
                'due to failed dependencies %s', name, dep)

        if failed_uploads:
            logger.error(
                'UPLOAD SUMMARY: the following packages failed to upload:\n%s',
                '\n'.join(failed_uploads))

        return False

    logger.info(
        "BUILD SUMMARY: successfully built %s of %s recipes",
        len(built_recipes), len(recipes))

    return all_success
