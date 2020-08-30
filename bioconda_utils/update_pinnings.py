"""
Determine which packages need updates after pinning change
"""

import enum
from itertools import chain
import logging
import re
import string

from .utils import RepoData
# FIXME: trim_build_only_deps is not exported via conda_build.api!
#        Re-implement it here or ask upstream to export that functionality.
from conda_build.metadata import trim_build_only_deps

# for type checking
from typing import AbstractSet, List, Set
from .recipe import Recipe, RecipeError
from conda_build.metadata import MetaData


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


def _get_build_variants(meta: MetaData) -> Set[str]:
    # This is the same behavior as in
    # conda_build.metadata.Metadata.get_hash_contents but without leaving out
    # "build_string_excludes" (python, r_base, etc.).
    dependencies = set(meta.get_used_vars())
    trim_build_only_deps(meta, dependencies)
    return dependencies


def skip_for_variants(meta: MetaData, variant_keys: AbstractSet[str]) -> bool:
    """Check if the recipe uses any given variant keys

    Args:
      meta: Variant MetaData object

    Returns:
      True if any variant key from variant_keys is used
    """
    dependencies = _get_build_variants(meta)

    return not dependencies.isdisjoint(variant_keys)


def will_build_variant(meta: MetaData) -> bool:
    """Check if the recipe variant will be built as currently rendered

    Args:
      meta: Variant MetaData object

    Returns:
      True if all extant build numbers are smaller than the one indicated
      by the variant MetaData.
    """
    build_numbers = RepoData().get_package_data(
        'build_number',
        name=meta.name(), version=meta.version(),
        platform=['linux', 'noarch'],
    )
    current_num = int(meta.build_number())
    res = all(num < current_num for num in build_numbers)
    if res:
        logger.debug("Package %s=%s will be built already because %s < %s)",
                     meta.name(), meta.version(),
                     max(build_numbers) if build_numbers else "N/A",
                     meta.build_number())
    return res


_legacy_build_string_prefixes = re.compile(
    '''
    ^
    (
        (?P<numpy>    np   [0-9]{2,9}) |
        (?P<python>   py   [0-9]{2,9}) |
        (?P<perl>     pl   [0-9]{2,9}) |
        (?P<lua>      lua  [0-9]{2,9}) |
        (?P<r_base>   r    [0-9]{2,9}) |
        (?P<mro_base> mro  [0-9]{3,9})
    )*
    ''',
    re.X,
)


# TODO: clean this mess up
def _have_partially_matching_build_id(meta):
    # Stupid legacy special handling:
    res = RepoData().get_package_data(
        'build',
        name=meta.name(), version=meta.version(),
        build_number=meta.build_number(),
        platform=['linux', 'noarch'],
    )
    is_noarch = bool(meta.noarch)
    current_build_id = meta.build_id()
    current_matches = _legacy_build_string_prefixes.match(current_build_id)
    current_prefixes = current_matches.groupdict()
    # conda-build add "special" substrings for some packages to the build
    # string (e.g., "py38", "pl526", ...). When we use `bypass_env_check` then
    # it does not add those substrings somehow (?).
    # But during the actual build, it adds those substrings even for run-only
    # dependencies (see "blast" recipe with its "perl" run-dep for example).
    #
    # FIXME: The following is probably how it _should_ be done.
    #  But we still have a lot of recipes that only define a requirements/build
    #  without a requirements/host section.  conda-build seems to do create
    #  host/build env how it sees fit then.  E.g.:
    #   conda search 'gmap=2017.10.30[build_number=6,subdir=linux-64]'|tail -n1
    #   Loading channels: done
    #   # Name                       Version           Build  Channel
    #   gmap                      2017.10.30      h2f06484_6  bioconda
    #   $ conda search 'gmap=2017.10.30[build_number=6,subdir=osx-64]'|tail -n1
    #   Loading channels: done
    #   # Name                       Version           Build  Channel
    #   gmap                      2017.10.30 pl526h977ceac_6  bioconda
    #
    # build_deps = [
    #     dep.split()[0].replace('-', '_')
    #     for dep in
    #     chain(
    #         meta.get_value('requirements/build', []),
    #         meta.get_value('requirements/host', []),
    #     )
    # ]
    # # noarch:python is handled in have_noarch_python_build_number
    # # but we might have noarch:generic recipes that use python.
    # # It probably doesn't matter which python is chosen then, so
    # # we also trim the "py*" prefix in that case here.
    # if is_noarch and current_prefixes['python']:
    #     current_build_id = current_build_id.replace(current_prefixes['python'], '')
    #
    # def is_matching_trimmed_build_id(build_id, current_build_id):
    #     matches = _legacy_build_string_prefixes.match(build_id)
    #     trimmed_build_id = build_id
    #     for prefix_key, prefix in matches.groupdict().items():
    #         if prefix:
    #             if prefix_key in build_deps:
    #                 continue
    #             if not (is_noarch and prefix_key == 'python'):
    #                 continue
    #             trimmed_build_id = trimmed_build_id.replace(prefix, '')
    #     if trimmed_build_id.startswith('_'):
    #         # If we trimmed everything but the number, no '_' is inserted.
    #         trimmed_build_id = trimmed_build_id[1:]
    #     if trimmed_build_id == current_build_id:
    #         return True
    #     return False
    def is_matching_trimmed_build_id(build_id, current_build_id):
        matches = _legacy_build_string_prefixes.match(build_id)
        trimmed_build_id = build_id
        trimmed_current_build_id = current_build_id
        for prefix_key, prefix in matches.groupdict().items():
            current_prefix = current_prefixes[prefix_key]
            if prefix != current_prefix:
                if prefix and current_prefix:
                    # noarch:python is handled in have_noarch_python_build_number
                    # but we might have noarch:generic recipes that use python.
                    # It probably doesn't matter which python is chosen then, so
                    # we also trim the "py*" prefix in that case here.
                    if not (is_noarch and prefix_key == 'python'):
                        return False
            if prefix:
                trimmed_build_id = trimmed_build_id.replace(prefix, '')
            if current_prefix:
                trimmed_current_build_id = trimmed_current_build_id.replace(current_prefix, '')
        if trimmed_build_id.startswith('_'):
            # If we trimmed everything but the number, no '_' is inserted.
            trimmed_build_id = trimmed_build_id[1:]
        if trimmed_current_build_id.startswith('_'):
            # If we trimmed everything but the number, no '_' is inserted.
            trimmed_current_build_id = trimmed_current_build_id[1:]
        if trimmed_build_id == trimmed_current_build_id:
            return True
        return False

    for build_id in res:
        if is_matching_trimmed_build_id(build_id, current_build_id):
            logger.debug("Package %s=%s=%s exists",
                         meta.name(), meta.version(), build_id)
            return True
    return False


def have_variant(meta: MetaData) -> bool:
    """Checks if we have an exact match to name/version/buildstring

    Args:
      meta: Variant MetaData object

    Returns:
      True if the variant's build string exists already in the repodata
    """
    res = RepoData().get_package_data(
        name=meta.name(), version=meta.version(), build=meta.build_id(),
        platform=['linux', 'noarch']
    )
    if res:
        logger.debug("Package %s=%s=%s exists",
                     meta.name(), meta.version(), meta.build_id())
        return True
    return _have_partially_matching_build_id(meta)


def have_noarch_python_build_number(meta: MetaData) -> bool:
    """Checks if we have a noarch:python build with same version+build_number

    Args:
      meta: Variant MetaData object

    Returns:
      True if noarch:python and version+build_number exists already in repodata
    """
    if meta.get_value('build/noarch') != 'python':
        return False
    res = RepoData().get_package_data(
        name=meta.name(), version=meta.version(),
        build_number=meta.build_number(),
        platform=['noarch'],
    )
    if res:
        logger.debug("Package %s=%s[build_number=%s, subdir=noarch] exists",
                     meta.name(), meta.version(), meta.build_number())
    return res


def will_build_only_missing(metas: List[MetaData]) -> bool:
    """Checks if only new builds will be added (no divergent build ids exist)

    Args:
      metas: List of Variant MetaData objects

    Returns:
      True if no divergent build strings exist in repodata
    """
    builds = {
        (meta.name(), meta.version(), meta.build_number())
        for meta in metas
    }
    existing_builds = set()
    for name, version, build_number in builds:
        existing_builds.update(
            map(
                tuple,
                RepoData().get_package_data(
                    ["name", "version", "build"],
                    name=name, version=version, build_number=build_number,
                    platform=['linux', 'noarch'],
                ),
            ),
        )
    new_builds = {
        (meta.name(), meta.version(), meta.build_id())
        for meta in metas
    }
    return new_builds.issuperset(existing_builds)


class State(enum.Flag):
    """Recipe Pinning State"""
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
    #: Recipe has a noarch:python variant that exists already
    HAVE_NOARCH_PYTHON = enum.auto()

    def needs_bump(self) -> bool:
        """Checks if the state indicates that the recipe needs to be bumped
        """
        return self & self.BUMP


    def failed(self) -> bool:
        """True if the update pinning check failed"""
        return self & self.FAIL


allowed_build_string_characters = frozenset(
    string.digits + string.ascii_uppercase + string.ascii_lowercase + '_.'
)


def has_invalid_build_string(meta: MetaData) -> bool:
    build_string = meta.build_id()
    return not (build_string and set(build_string).issubset(allowed_build_string_characters))


def check(
    recipe: Recipe,
    build_config,
    keep_metas=False,
    skip_variant_keys: AbstractSet[str] = frozenset(),
) -> State:
    """Determine if a given recipe should have its build number increments
    (bumped) due to a recent change in pinnings.

    Args:
      recipe: The recipe to check
      build_config: conda build config object
      keep_metas: If true, `Recipe.conda_release` is not called
      skip_variant_keys: Variant keys to skip a recipe for if they are used

    Returns:
      Tuple of state and a the input recipe
    """
    try:
        logger.debug("Calling Conda to render %s", recipe)
        maybe_metas = recipe.conda_render(config=build_config)
        logger.debug("Finished rendering %s", recipe)
    except RecipeError as exc:
        logger.error(exc)
        return State.FAIL, recipe
    except Exception as exc:
        logger.exception("update_pinnings.check failed with exception in api.render(%s):", recipe)
        return State.FAIL, recipe

    if maybe_metas is None:
        logger.error("Failed to render %s. Got 'None' from recipe.conda_render()", recipe)
        return State.FAIL, recipe

    metas = [meta for meta, _, _ in maybe_metas]
    if any(has_invalid_build_string(meta) for meta in metas):
        logger.error(
            "Failed to get build strings for %s with bypass_env_check. "
            "Probably needs build/skip instead of dep constraint.",
            recipe,
        )
        return State.FAIL, recipe

    flags = State(0)
    maybe_bump = False
    for meta in metas:
        if meta.skip() or skip_for_variants(meta, skip_variant_keys):
            flags |= State.SKIP
        elif have_noarch_python_build_number(meta):
            flags |= State.HAVE_NOARCH_PYTHON
        elif have_variant(meta):
            flags |= State.HAVE
        elif will_build_variant(meta):
            flags |= State.BUMPED
        else:
            logger.info("Package %s=%s=%s missing!",
                         meta.name(), meta.version(), meta.build_id())
            maybe_bump = True
    if maybe_bump:
        # Skip bump if we only add to the build matrix.
        if will_build_only_missing(metas):
            flags |= State.BUMPED
        else:
            flags |= State.BUMP
    if not keep_metas:
        recipe.conda_release()
    return flags, recipe
