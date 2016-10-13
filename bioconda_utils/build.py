import subprocess as sp
import os
import logging
import networkx as nx
from . import utils
from . import docker_utils
from . import pkg_test

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
        Channels to include via the `--channel` argument to conda-build

    docker_builder : docker_utils.RecipeBuilder object
        Use this docker builder to build the recipe, copying over the built
        recipe to the host's conda-bld directory.
    """

    logger.info(
        "Building and testing '%s' for environment %s",
        recipe, ';'.join(['='.join(i) for i in sorted(env)])
    )
    build_args = []
    if testonly:
        build_args.append("--test")
    else:
        build_args += ["--no-anaconda-upload"]

    channel_args = []
    if channels:
        for c in channels:
            channel_args.extend(['--channel', c])

    logger.debug('build_args: %s', build_args)
    logger.debug('channel_args: %s', channel_args)

    CONDA_BUILD_CMD = ['conda', 'build']

    try:
        if docker_builder is not None:
            response = docker_builder.build_recipe(
                recipe_dir=os.path.abspath(recipe),
                build_args=' '.join(channel_args + build_args),
                environment=dict(env)
            )
            logger.info('Successfully built %s', recipe)
            build_success = True
        else:
            p = sp.run(
                CONDA_BUILD_CMD + [recipe],
                stdout=sp.PIPE,
                stderr=sp.STDOUT,
                check=True,
                universal_newlines=True,
                env=utils.merged_env(env)
            )
            logger.debug(p.stdout)
            logger.debug(" ".join(p.args))
            logger.info('Successfully built %s', recipe)
            build_success = True
    except (docker_utils.DockerCalledProcessError, sp.CalledProcessError) as e:
            logger.error(e.stdout)
            logger.error(e.stderr)
            logger.error(e.cmd)
            build_success = False

    if not mulled_test:
        return build_success

    def pkgname(recipe, env):
        cmd = [
            "conda", "build", "--no-source", "--override-channels", "--output"
        ] + channel_args + [recipe]
        logger.debug(env)
        logger.debug(cmd)
        p = sp.run(
            cmd,
            check=True,
            stdout=sp.PIPE,
            stderr=sp.PIPE,
            universal_newlines=True,
            env=utils.merged_env(env))
        pkgpaths = p.stdout.strip().split("\n")
        assert len(pkgpaths) == 1
        return pkgpaths[0]

    pkg_path = pkgname(recipe, env)

    # TODO: better granularity; e.g. report if the build worked but test failed
    res = pkg_test.test_package(pkg_path)
    logger.info('mulled-build results: %s', res)


def test_recipes(recipe_folder,
                 config,
                 packages="*",
                 mulled_test=True,
                 testonly=False,
                 force=False,
                 docker=None):
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
        If True, build the recipe even though it would otherwise be filtered out.

    """
    config = utils.load_config(config)
    env_matrix = utils.EnvMatrix(config['env_matrix'])
    blacklist = utils.get_blacklist(config['blacklists'], recipe_folder)

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

    logger.info('Filtering recipes')
    recipe_targets = dict(
        utils.filter_recipes(recipes, env_matrix, config['channels'], force=force)
    )
    recipes = list(recipe_targets.keys())

    dag, name2recipes = utils.get_dag(recipes, blacklist=blacklist)

    if not dag:
        logger.info("Nothing to be done.")
        return True
    else:
        logger.info("Building and testing %s recipes in total", len(dag))
        logger.info("Recipes to build: \n%s", "\n".join(dag.nodes()))

    subdags_n = int(os.environ.get("SUBDAGS", 1))
    subdag_i = int(os.environ.get("SUBDAG", 0))

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

    builder = None
    if docker is not None:
        from docker import Client as DockerClient

        # Use the defaults for RecipeBuilder unless otherwise specified in
        # config file.
        kwargs = {}
        for key, argname in [
            ('docker_image', 'image'),
            ('requirements', 'requirements'),
            ('docker_url', 'base_url'),
        ]:
            if key in config:
                kwargs[argname] = config[key]

        builder = docker_utils.RecipeBuilder(**kwargs)

        logger.info('Done.')

    success = True
    for recipe in recipes:
        for target in recipe_targets[recipe]:
            success &= build(
                recipe=recipe,
                recipe_folder=recipe_folder,
                env=target.env,
                testonly=testonly,
                mulled_test=mulled_test,
                force=force,
                channels=config['channels'],
                docker_builder=builder
            )



    if not testonly:
        # upload builds
        if (os.environ.get("TRAVIS_BRANCH") == "master" and
                os.environ.get("TRAVIS_PULL_REQUEST") == "false"):
            for recipe in recipes:
                for target in recipe_targets[recipe]:
                    package = target.pkg
                    logger.debug(
                        "Checking existence of package {}".format(package)
                    )
                    if os.path.exists(package):
                        logger.info("Uploading package {}".format(package))
                        try:
                            sp.run(
                                ["anaconda", "-t",
                                 os.environ.get("ANACONDA_TOKEN"), "upload",
                                 package],
                                stdout=sp.PIPE,
                                stderr=sp.STDOUT,
                                check=True)
                        except sp.CalledProcessError as e:
                            print(e.stdout.decode(), file=sys.stderr)
                            if b"already exists" in e.stdout:
                                # ignore error assuming that it is caused by
                                # existing package
                                pass
                            else:
                                raise e
                    else:
                        logger.error(
                            "Package {} has not been built.".format(package)
                        )
                        success = False
    return success
