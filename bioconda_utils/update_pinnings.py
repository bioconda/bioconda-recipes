"""
Determine which packages need updates after pinning change
"""

import enum
import logging
import string

from .utils import RepoData
# FIXME: trim_build_only_deps is not exported via conda_build.api!
#        Re-implement it here or ask upstream to export that functionality.
from conda_build.metadata import trim_build_only_deps

# for type checking
from typing import AbstractSet
from .recipe import Recipe, RecipeError
from conda_build.metadata import MetaData


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


def skip_for_variants(meta: MetaData, variant_keys: AbstractSet[str]) -> bool:
    """Check if the recipe uses any given variant keys

    Args:
      meta: Variant MetaData object

    Returns:
      True if any variant key from variant_keys is used
    """
    # This is the same behavior as in
    # conda_build.metadata.Metadata.get_hash_contents but without leaving out
    # "build_string_excludes" (python, r_base, etc.).
    dependencies = set(meta.get_used_vars())
    trim_build_only_deps(meta, dependencies)

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
    return res


def have_variant_but_for_python(meta: MetaData) -> bool:
    """Checks if we have an exact or ``py[23]_`` prefixed match to
    name/version/buildstring

    Ignores osx.

    Args:
      meta: Variant MetaData object

    Returns:
      True if FIXME
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
    #: Recipe has a variant that needs bumping only for python
    BUMP_PYTHON_ONLY = enum.auto()

    def needs_bump(self, bump_python_only=True) -> bool:
        """Checks if the state indicates that the recipe needs to be bumped

        Args:
          bump_python_only: FIXME
        """
        if bump_python_only:
            return self & (self.BUMP | self.BUMP_PYTHON_ONLY)
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
        metas = recipe.conda_render(config=build_config)
        logger.debug("Finished rendering %s", recipe)
    except RecipeError as exc:
        logger.error(exc)
        return State.FAIL, recipe
    except Exception as exc:
        logger.exception("update_pinnings.check failed with exception in api.render(%s):", recipe)
        return State.FAIL, recipe

    if metas is None:
        logger.error("Failed to render %s. Got 'None' from recipe.conda_render()", recipe)
        return State.FAIL, recipe

    if any(has_invalid_build_string(meta) for meta, _, _ in metas):
        logger.error(
            "Failed to get build strings for %s with bypass_env_check. "
            "Probably needs build/skip instead of dep constraint.",
            recipe,
        )
        return State.FAIL, recipe

    flags = State(0)
    for meta, _, _ in metas:
        if meta.skip() or skip_for_variants(meta, skip_variant_keys):
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
    if not keep_metas:
        recipe.conda_release()
    return flags, recipe
