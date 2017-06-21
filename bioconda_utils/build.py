import subprocess as sp
from collections import defaultdict, namedtuple
import os
import logging
import networkx as nx
from . import utils
from . import docker_utils
from . import pkg_test
from . import upload
from conda_build import api

logger = logging.getLogger(__name__)


BuildResult = namedtuple("BuildResult", ["success", "mulled_image"])


def purge():
    utils.run(["conda", "build", "purge"])

    free = utils.get_free_space()
    if free < 10:
        logger.info("CLEANING UP PACKAGE CACHE (free space: %iMB).", free)
        utils.run(["conda", "clean" "--all"])
        logger.info("CLEANED UP PACKAGE CACHE (free space: %iMB).",
                    utils.get_free_space())


def build(recipe,
          recipe_folder,
          env,
          testonly=False,
          mulled_test=True,
          force=False,
          channels=None,
          docker_builder=None,
    ):
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

    # Clean provided env and exisiting os.environ to only allow whitelisted env
    # vars
    _env = {}
    _env.update({k:str(v) for k, v in os.environ.items() if utils.allowed_env_var(k)})
    _env.update({k:str(v) for k, v in dict(env).items() if utils.allowed_env_var(k)})

    logger.info(
        "BUILD START %s, env: %s",
        recipe, ';'.join(['='.join(map(str, i)) for i in sorted(_env.items())])
    )

    # --no-build-id is needed for some very long package names that triggers the 89 character limits
    # this option can be removed as soon as all packages are rebuild with the 255 character limit
    # Moreover, --no-build-id will block us from using parallel builds in conda-build 2.x
    # build_args = ["--no-build-id"]

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

    CONDA_BUILD_CMD = ['conda', 'build']

    try:
        # Note we're not sending the contents of os.environ here. But we do
        # want to add TRAVIS* vars if that behavior is not disabled.
        if docker_builder is not None:

            response = docker_builder.build_recipe(
                recipe_dir=os.path.abspath(recipe),
                build_args=' '.join(channel_args + build_args),
                env=_env
            )

            pkg = utils.built_package_path(recipe, _env)
            if not os.path.exists(pkg):
                logger.error(
                    "BUILD FAILED: the built package %s "
                    "cannot be found", pkg)
                return BuildResult(False, None)
            build_success = True
        else:

            # Temporarily reset os.environ to avoid leaking env vars to
            # conda-build, and explicitly provide `env` to `run()`
            # we explicitly point to the meta.yaml, in order to keep
            # conda-build from building all subdirectories
            with utils.sandboxed_env(_env):
                cmd = CONDA_BUILD_CMD + build_args + channel_args + \
                      [os.path.join(recipe, 'meta.yaml')]
                logger.debug('command: %s', cmd)
                with utils.Progress():
                    p = utils.run(cmd, env=os.environ)

            build_success = True

        logger.info(
            'BUILD SUCCESS %s, %s',
            utils.built_package_path(recipe, _env), utils.envstr(_env)
        )

    except (docker_utils.DockerCalledProcessError, sp.CalledProcessError) as e:
            logger.error(
                'BUILD FAILED %s, %s', recipe, utils.envstr(env))
            return BuildResult(False, None)

    if not mulled_test:
        return BuildResult(True, None)

    pkg_path = utils.built_package_path(recipe, _env)

    logger.info(
        'TEST START via mulled-build %s, %s',
        recipe, utils.envstr(_env))

    use_base_image = utils.get_meta_value(
        utils.load_meta(recipe, env),
        'extra', 'container', 'extended-base')
    base_image = 'bioconda/extended-base-image' if use_base_image else None

    try:
        res = pkg_test.test_package(pkg_path, base_image=base_image)

        logger.info("TEST SUCCESS %s, %s", recipe, utils.envstr(_env))
        mulled_image = pkg_test.get_image_name(pkg_path)
        return BuildResult(True, mulled_image)
    except sp.CalledProcessError as e:
        logger.error('TEST FAILED: %s, %s', recipe, utils.envstr(_env))
        return BuildResult(False, None)


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
        return True

    logger.debug('recipes: %s', recipes)

    logger.info('Filtering recipes')
    recipe_targets = dict(
        utils.filter_recipes(
            recipes, env_matrix, check_channels, force=force)
    )
    recipes = set(list(recipe_targets.keys()))

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
        subdag_i + 1, subdags_n, len(recipes)
    )

    failed = []
    built_recipes = []
    skipped_recipes = []
    all_success = True
    failed_uploads = []
    skip_dependent = defaultdict(list)

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

        for target in recipe_targets[recipe]:

            res = build(
                recipe=recipe,
                recipe_folder=recipe_folder,
                env=target.env,
                testonly=testonly,
                mulled_test=mulled_test,
                force=force,
                channels=config['channels'],
                docker_builder=docker_builder,
            )

            all_success &= res.success
            recipe_success &= res.success

            if not res.success:
                failed.append((recipe, target))
                for n in nx.algorithms.descendants(subdag, name):
                    skip_dependent[n].append(recipe)
            elif not testonly:
                # upload build
                if anaconda_upload:
                    if not upload.anaconda_upload(target.pkg, label):
                        failed_uploads.append(target.pkg)
                if mulled_upload_target:
                    upload.mulled_upload(res.mulled_image, mulled_upload_target)

            # remove traces of the build
            purge()

        if recipe_success:
            built_recipes.append(recipe)

    if failed or failed_uploads:
        failed_recipes = set(i[0] for i in failed)
        logger.error(
            'BUILD SUMMARY: of %s recipes, '
            '%s failed and %s were skipped. '
            'Details of recipes and environments follow.',
            len(recipes), len(failed_recipes), len(skipped_recipes))

        if len(built_recipes) > 0:
            logger.error(
                'BUILD SUMMARY: while the entire build failed, '
                'the following recipes were built successfully:\n%s',
                '\n'.join(built_recipes))

        for recipe, target in failed:
            logger.error(
                'BUILD SUMMARY: FAILED recipe %s, environment %s',
                str(target), target.envstring())

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
