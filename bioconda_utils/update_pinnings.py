import re
import sys
import os.path
import logging
import collections
import enum

import networkx as nx

from .utils import RepoData, load_conda_build_config, parallel_iter

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


buildNumberRegex = re.compile("^( +number: +)(\d+)(.*?)$")
buildNumberJinja = re.compile("^({% +set build +=.+?)(\d+)(.*?%})")


def will_build_variant(meta):
    """Check if the recipe variant will be built as currently rendered"""
    build_numbers = RepoData().get_package_data(
        'build_number',
        name=meta.name(), version=meta.version(),
        platform=['linux', 'noarch'],
    )
    res = all(num < meta.build_number() for num in build_numbers)
    if res:
        logger.debug("Package %s=%s will be built already because %s < %s)",
                     meta.name(), meta.version(),
                     max(build_numbers) if build_numbers else "N/A",
                     meta.build_number())
    return res


def have_variant(meta):
    """Checks if we have an exact match to name/version/buildstring
    """
    res = RepoData().get_package_data(
        name=meta.name(), version=meta.version(), build=meta.build_id(),
        platform=['linux', 'noarch']
    )
    if res:
        logger.debug("Package %s=%s=%s exists",
                     meta.name(), meta.version(), meta.build_id())
    return res


def have_variant_but_for_python(meta):
    """Checks if we have an exact or `py[23]_` prefixed match to
    name/version/buildstring

    Ignores osx.
    """
    def strip_py(build):
        if build.startswith("py"):
            return build[4:]
        return build

    builds = RepoData().get_package_data(
        'build',
        name=meta.name(), version=meta.version(),
        platform=['linux', 'noarch']
    )
    res = [build for build in builds
           if strip_py(build) == strip_py(meta.build_id())]
    if res:
        logger.debug("Package %s=%s has %s (want %s)",
                     meta.name(), meta.version(), res, meta.build_id())
    return bool(res)



class State(enum.Flag):
    #: Recipe had a failure rendering
    FAIL = enum.auto()
    #: Recipe has a variant that will be skipped
    SKIP = enum.auto()
    #: Recipe has a variant that exists already
    HAVE = enum.auto()
    #: Recipe has a variant that was bumped already
    BUMPED = enum.auto()
    #: Recipe has a variant that needs bumping
    BUMP = enum.auto()
    #: Recipe has a variant that needs bumping only for python
    BUMP_PYTHON_ONLY = enum.auto()

    def needs_bump(self, bump_python_only=True):
        if bump_python_only:
            return self & (self.BUMP | self.BUMP_PYTHON_ONLY)
        return self & self.BUMP

    def failed(self):
        return self & self.FAIL


def check(recipe, build_config) -> State:
    """
    Determine if a given recipe should have its build number increments
    (bumped) due to a recent change in pinnings.
    """
    try:
        logger.debug("Calling Conda to render %s", recipe)
        rendered = recipe.conda_render(config=build_config,
                                       permit_unsatisfiable_variants=False)
        logger.debug("Finished rendering %s", recipe)
    except Exception as exc:
        logger.debug("Exception rendering %s: %s", recipe, exc)
        return State.FAIL

    flags = State(0)
    for meta, _, _ in rendered:
        if meta.skip():
            flags |= State.SKIP
        elif have_variant(meta):
            flags |= State.HAVE
        elif will_build_variant(meta):
            flags |= State.BUMPED
        elif have_variant_but_for_python(meta):
            flags |= State.BUMP_PYTHON_ONLY
        else:
            logger.info("Package %s=%s=%s missing!",
                         meta.name(), meta.version(), meta.build_id())
            flags |= State.BUMP
    return flags


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
