#!/usr/bin/env python
from conda_build import api
import re
import sys
import os.path
buildNumberRegex = re.compile("^( +number: +)(\d+)(.*?)$")
buildNumberJinja = re.compile("^({% +set build +=.+?)(\d+)(.*?%})")

def already_bumped(r, name, version, buildNumber):
    rsub = r.loc[(r.name == name) &
             (r.platform != "osx") &
             (r.version == version)]
    if rsub.shape[0] == 0:
        # The version was never built, it doesn't explicitly require bumping
        return True
    if buildNumber > max(rsub.build_number):
        # Already bumped
        return True
    return False


def already_built(r, name, version, buildstring):
    if r.loc[(r.name == name) &
             (r.platform != "osx") &
             (r.version == version) &
             (r.build == buildstring)].shape[0] > 0:
        return True
    return False


def only_python(r, name, version, buildstring):
    s = r.loc[(r.name == name) &
              (r.platform != "osx") &
              (r.version == version)]
    if s.shape[0] == 0:
        # Version doesn't exist in linux/noarch
        return False
    build_set = set()
    for b in s.build:
        bs = b.split("_")
        if bs[0].startswith("py"):
            build_set.add(bs[0][4:])
        else:
            build_set.add(bs[0])
    if buildstring in build_set:
        return True
    # Version exists, but build doesn't
    return False


def should_be_bumped(recipe, build_config, repodata):
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
        for renderedMeta, _, _ in api.render(recipe, config=build_config, permit_unsatisfiable_variants=False):
            if renderedMeta.skip():
                continue
            buildID = renderedMeta.build_id()  # e.g., py36h47cebea_1 or 0
            # This doesn't work for noarch: python, which is just py_0 or pyhXXXX_1
            # However those won't ever need to be rebuilt due to only a python version change
            buildID_nopy = buildID[4:] if buildID.startswith("py") else buildID

            if already_bumped(repodata, renderedMeta.name(), renderedMeta.version(), renderedMeta.build_number()):
                # Don't double bump
                continue
            if already_built(repodata, renderedMeta.name(), renderedMeta.version(), buildID):
                continue
            if only_python(repodata, renderedMeta.name(), renderedMeta.version(), buildID_nopy):
                status = max(1, status)
                continue
            status = max(2, status)
    except:
        print(sys.exc_info()[1])
        status = 3
    return status


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
