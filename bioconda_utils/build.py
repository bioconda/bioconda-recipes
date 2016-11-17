import subprocess as sp
from collections import defaultdict
import os
import logging
import networkx as nx
from . import utils
from . import docker_utils
from . import pkg_test
from . import upload
from conda_build import api

logger = logging.getLogger(__name__)


def build(recipe,
          recipe_folder,
          env,
          testonly=False,
          mulled_test=True,
          force=False,
          channels=None,
          docker_builder=None):
    """
    Build a single recipe for a single env

    Parameters
    ----------
    recipe : str
        Path to recipe

    env : dict
        Environment (typically a single yielded dictionary from EnvMatrix
        instance)

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
    """
    env = dict(env)
    logger.info(
        "BIOCONDA BUILD START %s, env: %s",
        recipe, ';'.join(['='.join(map(str, i)) for i in sorted(env.items())])
    )
    # --no-build-id is needed for some very long package names that triggers the 89 character limits
    # this option can be removed as soon as all packages are rebuild with the 255 character limit
    # Moreover, --no-build-id will block us from using parallel builds in conda-build 2.x
    build_args = ["--no-build-id"]
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

    CONDA_BUILD_CMD = ['conda', 'build']

    try:
        # Note we're not sending the contents of os.environ here
        if docker_builder is not None:
            response = docker_builder.build_recipe(
                recipe_dir=os.path.abspath(recipe),
                build_args=' '.join(channel_args + build_args),
                env=env
            )

            pkg = utils.built_package_path(recipe, env)
            if not os.path.exists(pkg):
                logger.error(
                    "BIOCONDA BUILD FAILED: the built package %s "
                    "cannot be found", pkg)
                return False
            build_success = True
        else:
            # Since we're calling out to shell and we want to send at least
            # some env vars send them all via the temporarily-reset os.environ.
            with utils.temp_env(env):
                cmd = CONDA_BUILD_CMD + build_args + channel_args + [recipe]
                logger.debug('command: %s', cmd)
                p = utils.run(cmd, env=os.environ)

            build_success = True

        logger.info(
            'BIOCONDA BUILD SUCCESS %s, %s',
            utils.built_package_path(recipe, env), utils.envstr(env)
        )

    except (docker_utils.DockerCalledProcessError, sp.CalledProcessError) as e:
            logger.error(
                'BIOCONDA BUILD FAILED %s, %s', recipe, utils.envstr(env))
            logger.error('COMMAND: %s', ' '.join(e.cmd))
            logger.error('STDOUT+STDERR: %s', e.stdout)
            return False

    if not mulled_test:
        return True

    pkg_path = utils.built_package_path(recipe, env)

    logger.info(
        'BIOCONDA TEST START via mulled-build %s, %s',
        recipe, utils.envstr(env))

    res = pkg_test.test_package(pkg_path)

    # TODO remove the second clause once new galaxy-lib has been released.
    if (res.returncode == 0) and (res.stdout.find('Unexpected exit code') == -1):
        logger.info("BIOCONDA TEST SUCCESS %s, %s", recipe, utils.envstr(env))
        logger.debug('STDOUT:\n%s', res.stdout)
        logger.debug('STDERR:\n%s', res.stderr)
        return True
    else:
        logger.error('BIOCONDA TEST FAILED: %s, %s', recipe, utils.envstr(env))
        logger.error('STDOUT:\n%s', res.stdout)
        logger.error('STDERR:\n%s', res.stderr)
        return False


def build_recipes(
    recipe_folder,
    config,
    packages="*",
    mulled_test=True,
    testonly=False,
    force=False,
    docker_builder=None,
    label=None,
    disable_upload=False,
    check_channels=None,
    quick=False,
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

    disable_upload :  bool
        If True, do not upload the package. Useful for testing.

    check_channels : list
        Channels to check to see if packages already exist in them. If None,
        then defaults to the highest-priority channel (that is,
        `config['channels'][0]`). If this list is empty, then do not check any
        channels.

    quick : bool
        Speed up recipe filtering by only checking those that are reasonably
        new.
    """
    orig_config = config
    config = utils.load_config(config)
    env_matrix = utils.EnvMatrix(config['env_matrix'])
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
        return

    logger.debug('recipes: %s', recipes)
    if quick:
        if not isinstance(orig_config, str):
            raise ValueError("Need a config filename (and not a dict) for "
                             "quick filtering since we need to check that "
                             "file in the master branch")
        unblacklisted = [
            os.path.join(recipe_folder, i)
            for i in utils.newly_unblacklisted(orig_config, recipe_folder)
        ]
        logger.debug('Unblacklisted: %s', unblacklisted)
        changed = [
            os.path.join(recipe_folder, i) for i in
            utils.changed_since_master(recipe_folder)
        ]
        logger.debug('Changed: %s', changed)
        recipes = set(unblacklisted + changed).intersection(recipes)
        logger.debug('Quick-filtered recipes: %s', recipes)

    logger.info('Filtering recipes')
    recipe_targets = dict(
        utils.filter_recipes(
            recipes, env_matrix, check_channels, force=force)
    )
    recipes = list(recipe_targets.keys())

    dag, name2recipes = utils.get_dag(recipes, blacklist=blacklist)
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

    # Get connected subdags and sort by nodes
    if testonly:
        # use each node as a subdag (they are grouped into equal sizes below)
        subdags = sorted([[n] for n in nx.nodes(dag)])
    else:
        # take connected components as subdags
        subdags = sorted(map(sorted, nx.connected_components(dag.to_undirected(
        ))))
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

    # ensure that packages which need a build are built in the right order
    recipes = [recipe
               for package in nx.topological_sort(subdag)
               for recipe in name2recipes[package]]

    logger.info(
        "Building and testing subdag %s of %s (%s recipes)",
        subdag_i, subdags_n, len(recipes)
    )

    failed = []
    built_recipes = []
    skipped_recipes = []
    all_success = True
    skip_dependent = defaultdict(list)

    for recipe in recipes:
        recipe_success = True
        name = recipe2name[recipe]

        if name in skip_dependent:
            logger.info(
                'BIOCONDA BUILD SKIP: '
                'skipping %s because it depends on %s '
                'which had a failed build.',
                recipe, skip_dependent[name])
            skipped_recipes.append(recipe)
            continue

        for target in recipe_targets[recipe]:

            target_success = build(
                recipe=recipe,
                recipe_folder=recipe_folder,
                env=target.env,
                testonly=testonly,
                mulled_test=mulled_test,
                force=force,
                channels=config['channels'],
                docker_builder=docker_builder
            )

            all_success &= target_success
            recipe_success &= target_success

            if not target_success:
                failed.append((recipe, target))
                for n in nx.algorithms.descendants(subdag, name):
                    skip_dependent[n].append(recipe)

        if recipe_success:
            built_recipes.append(recipe)

    if len(failed) > 0:
        failed_recipes = list(set(i[0] for i in failed))
        logger.error(
            'BIOCONDA BUILD SUMMARY: of %s recipes, '
            '%s failed and %s were skipped. '
            'Details of recipes and environments follow.',
            len(recipes), len(failed_recipes), len(skipped_recipes))

        if len(built_recipes) > 0:
            logger.error(
                'BIOCONDA BUILD SUMMARY: while the entire build failed, '
                'the following recipes were built successfully:\n%s',
                '\n'.join(built_recipes))

        for recipe, target in failed:
            logger.error(
                'BIOCONDA BUILD SUMMARY: FAILED recipe %s, environment %s',
                str(target), target.envstring())

        for name, dep in skip_dependent.items():
            logger.error(
                'BIOCONDA BUILD SUMMARY: SKIPPED recipe %s '
                'due to failed dependencies %s', name, dep)
        return False

    logger.info(
        "BIOCONDA BUILD SUMMARY: successfully built %s of %s recipes",
        len(built_recipes), len(recipes))

    if not testonly and not disable_upload:
        # upload builds
        if (os.environ.get("TRAVIS_BRANCH") == "master" and
                os.environ.get("TRAVIS_PULL_REQUEST") == "false"):
            for recipe in recipes:
                for target in recipe_targets[recipe]:
                    all_success &= upload.upload(target.pkg, label)
    return all_success
