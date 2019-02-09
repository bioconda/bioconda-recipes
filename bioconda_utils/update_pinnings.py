import re
import sys
import os.path
import logging
import collections
from contextlib import redirect_stdout, redirect_stderr

from conda_build import api
import networkx as nx

from .utils import RepoData, load_conda_build_config, parallel_iter

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


buildNumberRegex = re.compile("^( +number: +)(\d+)(.*?)$")
buildNumberJinja = re.compile("^({% +set build +=.+?)(\d+)(.*?%})")


def already_bumped(name, version, buildNumber):
    """Checks if recipe does not need to be bumped (again)

    That is the case if all packages existing for the name/version
    combination have a build number smaller than the one the recipe
    currently has.

    (If there is no package at all yet, "all" is true)

    Ignores osx.
    """
    return all(
        num < buildNumber
        for num in RepoData().get_package_data(
        'build_number',
        name=name, platform=['linux', 'noarch'], version=version)
    )


def already_built(name, version, buildstring):
    """Checks if we have an exact match to name/version/buildstring

    Ignores osx.
    """
    return RepoData().get_package_data(
        name=name, platform=['linux', 'noarch'], version=version,
        build=buildstring)


def only_python(name, version, buildstring):
    """Checks if we have an exact or `py[23]_` prefixed match to
    name/version/buildstring

    Ignores osx.
    """
    return any(
        (bs.startswith("py") and bs[4:] == buildstring) or bs == buildstring
        for bs in RepoData().get_package_data(
                'build',
                name=name, platform=['linux', 'noarch'], version=version)
    )


def should_be_bumped(recipe, build_config):
    """
    Determine if a given recipe should have its build number increments
    (bumped) due to a recent change in pinnings.

    The output is an integer between 0 and 4:

    0: A change in pinnings has no affect on the given recipe.
    1: A bump is not explicitly needed, but a new python build is required.
    2: A recipe's build number should be bumped.
    3: conda-build returned an error while rendering the recipe.
    """
    status = 0
    try:
        with open("/dev/null", "w") as devnull:
            with redirect_stdout(devnull), redirect_stderr(devnull):
                # api.render uses print WAYYY too much
                rendered = api.render(recipe, config=build_config, permit_unsatisfiable_variants=False)
        for renderedMeta, _, _ in rendered:
            if renderedMeta.skip():
                continue
            buildID = renderedMeta.build_id()  # e.g., py36h47cebea_1 or 0
            # This doesn't work for noarch: python, which is just py_0 or pyhXXXX_1
            # However those won't ever need to be rebuilt due to only a python version change
            buildID_nopy = buildID[4:] if buildID.startswith("py") else buildID

            if already_bumped(renderedMeta.name(), renderedMeta.version(), renderedMeta.build_number()):
                # Don't double bump
                continue
            if already_built(renderedMeta.name(), renderedMeta.version(), buildID):
                continue
            if only_python(renderedMeta.name(), renderedMeta.version(), buildID_nopy):
                status = max(1, status)
                continue
            status = max(2, status)
    except Exception:
        logger.exception("Failed to check if recipe %s should be bumped")
        status = 3
    return status


def _call_should_be_bumped(arg):
    return should_be_bumped(*arg), arg[0]


def iter_recipes_to_bump(dag, name2recipes, bump_only_python):
    build_config = load_conda_build_config()
    build_config.trim_skip = True

    recipes = [(recipe, build_config)
               for node in nx.nodes(dag)
               for recipe in name2recipes[node]]

    RepoData().df  # trigger load

    yield from parallel_iter(_call_should_be_bumped,recipes, "Iterating")


def bump_recipe(recipe):
    """
    Increment the build number of a recipe

    returns True on success and False on error (the build number couldn't be updated)
    """
    m = open(os.path.join(recipe, "meta.yaml")).read().split("\n")
    found = False
    for idx, line in enumerate(m):
        matches = buildNumberRegex.match(line)
        if matches:
            found = True
            buildNumber = int(matches.group(2))
            m[idx] = "{}{}{}".format(matches.group(1), buildNumber + 1, matches.group(3))
            break
    if not found:
        for idx, line in enumerate(m):
            matches = buildNumberJinja.match(line)
            if matches:
                found = True
                buildNumber = int(matches.group(2))
                m[idx] = "{}{}{}".format(matches.group(1), buildNumber + 1, matches.group(3))
                break

    if found:
        f = open(os.path.join(recipe, "meta.yaml"), "w")
        f.write("\n".join(m))
        return True
    return False
