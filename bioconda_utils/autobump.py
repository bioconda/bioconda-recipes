"""Updates packages when new upstream releases become available

Overview:

- The `Scanner` initializes the `asyncio` loop and for each recipe,
  loads the ``meta.yaml`` using `Recipe` and executes its `Filter`
  objects for each recipe.

- The `Recipe` handles reading, modification and writing of
  ``meta.yaml`` files.

- The filters `ExcludeSubrecipe` and `ExcludeOtherChannel` exclude
  recipes in sub folders and present in other channels as configured.

- The filter `ExcludeNoActiveUpdate` excludes packages that don't
  already have an ongoing autobump update.

- The filters `LoadRecipe` and `GitLoadRecipe` fill the stub
  Recipe with content.

- The filter `UpdateVersion` determines available upstream verions
  using `Hoster` and its subclasses, selects the most recent,
  acceptable version and uses `Recipe` to replace

- The filter `FetchUpstreamDependencies` gathers additional
  dependencies not found by the `UpdateVersion` filter. (Currently,
  that's only trying to get Python deps by loading the ``setup.py``)

- The filter `UpdateChecksums` downloads the modified source URLs
  and updates the checksums for each source of a recipe.

- The filter `WriteRecipe` or the filter `GitWriteRecipe` are used to
  write the recipe back, either to the current folder structure, or
  the git repo and creating a branch.

- The filter `CreatePullRequest` creates pull requests on GitHub for
  changes made to per-recipe-branches.

- The filter `MaxUpdates` terminates the loop after a number of recipes
  have come past it, to avoid too many PRs opened at once.
"""

import abc
import asyncio
import logging
import os
import pickle
import random

from collections import defaultdict, Counter
from functools import partial
from urllib.parse import urlparse
from typing import (Any, Dict, Iterable, List, Mapping, Optional, Sequence,
                    Set, Tuple, TYPE_CHECKING)

import aiofiles
from aiohttp import ClientResponseError

import networkx as nx

import conda_build.variants
import conda_build.config
from conda.exports import MatchSpec, VersionOrder
import conda.exceptions

from pkg_resources import parse_version

from . import __version__
from . import utils
from . import update_pinnings
from . import graph
from .utils import ensure_list, RepoData
from .recipe import Recipe
from .recipe import load_parallel_iter as recipes_load_parallel_iter
from .aiopipe import AsyncFilter, AsyncPipeline, AsyncRequests, EndProcessingItem, EndProcessing

from .githandler import GitHandler
from .githubhandler import AiohttpGitHubHandler, GitHubHandler

# pkg_resources.parse_version returns a Version or LegacyVersion object
# as defined in packaging.version. Since it's bundling it's own copy of
# packaging, the class it returns is not the same as the one we can import.
# So we cheat by having it create a LegacyVersion delibarately.
LegacyVersion = parse_version("").__class__  # pylint: disable=invalid-name


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class RecipeSource:
    """Source for **Recipe** objects to feed into Scanner

    Args:
      packages: list of packages, may contain globs
      shuffle: If true, package order will be randomized.
    """
    def __init__(self, recipe_base: str, packages: List[str], exclude: List[str],
                 shuffle: bool=True) -> None:
        self.recipe_base = recipe_base
        self.recipe_dirs = list(utils.get_recipes(recipe_base, packages, exclude))
        if shuffle:
            random.shuffle(self.recipe_dirs)
        logger.warning("Selected %i packages", len(self.recipe_dirs))

    async def queue_items(self, send_q, return_q):
        n_items = 0
        for recipe_dir in self.recipe_dirs:
            await send_q.put(Recipe(recipe_dir, self.recipe_base))
            n_items += 1
            while return_q.qsize():
                try:
                    return_q.get_nowait()
                    return_q.task_done()
                    n_items -= 1
                except asyncio.QueueEmpty:
                    break
        for n in range(n_items):
            await return_q.get()
            return_q.task_done()

    def get_item_count(self):
        return len(self.recipe_dirs)


class RecipeGraphSource(RecipeSource):
    def __init__(self, recipe_base: str, packages: List[str], exclude: List[str],
                 shuffle: bool, config: Dict[str, str], cache_fn: str = None) -> None:
        super().__init__(recipe_base, packages, exclude, shuffle)
        self.config = config
        self.cache_fn = cache_fn
        self.shuffle = shuffle
        self.dag = self.load_graph()
        self.dag = graph.filter_recipe_dag(self.dag, packages, exclude)
        logger.warning("Graph contains %i packages (blacklist excluded)", len(self.dag))

    async def queue_items(self, send_q, return_q):
        # Build a copy of the graph we can meddle with
        dag = self.dag.__class__()
        dag.add_nodes_from(self.dag)
        dag.add_edges_from(self.dag.edges())
        # Keep set of recipes "in flight"
        sent: Set[Recipe] = set()
        while dag:
            remaining_recipes = dag.nodes()
            if self.shuffle:
                random.shuffle(remaining_recipes)
            for recipe in remaining_recipes:
                if recipe not in sent and dag.in_degree(recipe) == 0:
                    await send_q.put(recipe)
                    sent.add(recipe)
            item = await return_q.get()
            dag.remove_node(item)
            sent.remove(item)
            return_q.task_done()

    def get_item_count(self):
        return len(self.dag)

    def load_graph(self):
        if self.cache_fn and os.path.exists(self.cache_fn):
            with open(self.cache_fn, "rb") as stream:
                dag = pickle.load(stream)
        else:
            blacklist = utils.get_blacklist(self.config, self.recipe_base)
            dag = graph.build_from_recipes(
                recipe for recipe in recipes_load_parallel_iter(self.recipe_base, "*")
                if recipe.reldir not in blacklist
            )
            if self.cache_fn:
                with open(self.cache_fn, "wb") as stream:
                    pickle.dump(dag, stream)
        return dag


class Scanner(AsyncPipeline[Recipe]):
    """Scans recipes and applies filters in asyncio loop

    Arguments:
      recipe_source: Iteratable providing Recipe stubs
      cache_fn: Filename prefix for caching
      status_fn: Filename for status output
    """
    def __init__(self, recipe_source: Iterable[Recipe],
                 cache_fn: str = None,
                 status_fn: str = None) -> None:
        super().__init__()
        #: recipe source
        self.recipe_source = recipe_source
        #: counter to gather stats on various states
        self.stats: Counter = Counter()
        #: collect end status for each recipe
        self.status: List[Tuple[str, str]] = []
        #: filename to write statuses to
        self.status_fn: str = status_fn
        #: async requests helper
        self.req = AsyncRequests(cache_fn)

    def run(self) -> bool:
        """Runs scanner"""
        logger.info("Running pipeline with these steps:")
        for n, filt in enumerate(self.filters):
            logger.info(" %i. %s", n+1, filt.get_info())
        res = super().run()
        logger.info("")
        logger.info("Recipe status statistics:")
        for key, value in self.stats.most_common():
            logger.info("%s: %s", key, value)
        logger.info("SUM: %i", sum(self.stats.values()))
        if self.status_fn:
            with open(self.status_fn, "w") as out:
                for rname, result in self.status:
                    out.write(f'{rname}\t{result.name}\n')
        return res

    async def queue_items(self, send_q, return_q):
        await self.recipe_source.queue_items(send_q, return_q)

    def get_item_count(self):
        return self.recipe_source.get_item_count()

    async def _async_run(self) -> bool:
        """Runner within async loop"""
        async with self.req:
            return await super()._async_run()

    async def process(self, recipe: Recipe) -> bool:
        """Applies the filters to a recipe"""
        try:
            res = False
            if await super().process(recipe):
                self.stats["Updated"] += 1
                res = True
            return False
        except EndProcessingItem as recipe_error:
            self.stats[recipe_error.name] += 1
            self.status.append((recipe.reldir, recipe_error))
            res = True
        return res


class Filter(AsyncFilter[Recipe]):
    """Filter for Scanner - class exists primarily to silence mypy"""
    pipeline: Scanner

    def get_info(self) -> str:
        """Return description of filter for logging"""
        docline, _, _ = self.__class__.__doc__.partition("\n")
        return docline

    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> None:
        """Process a recipe. Returns False if processing should stop"""


class ExcludeOtherChannel(Filter):
    """Exclude recipes in **channels**"""

    class OtherChannel(EndProcessingItem):
        """This recipe builds one or more packages that are also present
        in at least one other channel"""
        template = "builds package found in other channel(s)"
        level = logging.DEBUG

    def __init__(self, scanner: Scanner, channels: Sequence[str],
                 cache: str) -> None:
        super().__init__(scanner)
        self.channels = channels
        logger.info("Loading package lists for %s", channels)
        repo = utils.RepoData()
        if cache:
            repo.set_cache(cache)
        self.other = set(repo.get_package_data('name', channels=channels))

    def get_info(self) -> str:
        return super().get_info().replace('**channels**', ', '.join(self.channels))

    async def apply(self, recipe: Recipe) -> None:
        if any(package in self.other
               for package in recipe.package_names):
            raise self.OtherChannel(recipe)


class AutoBumpConfigMixin:
    #: Name of key under ``extra`` containing config for autobump
    EXTRA_CONFIG = "autobump"
    #: Name of key under `EXTRA_CONFIG` to enable/disable autobump
    ENABLE = "enable"

    def get_config(self, recipe) -> Dict[Any, Any]:
        """Returns the configuration dict from the recipe"""
        return recipe.get("extra", {}).get(self.EXTRA_CONFIG, {})

    def is_enabled(self, recipe) -> Optional[bool]:
        """Checks if autobump is enabled for the recipe

        The result is:

        - `True` if the recipe is explicitly enabled (overriding e.g.
          exclusion of sub-recipes).
        - `False` if the recipe is explicitly disabled (e.g.
          if it is written in a way that cannot be updated automatically)
        - `None` if no explicit setting is present.
        """
        return self.get_config(recipe).get(self.ENABLE)


class ExcludeSubrecipe(Filter, AutoBumpConfigMixin):
    """Exclude sub-recipes

    Unless **always** is True, subrecipes specifically enabled via
    ``extra: watch: enable: yes`` will not be filtered.
    """

    class IsSubRecipe(EndProcessingItem):
        """This recipe is a sub-recipe (i.e. blast/2.4.0)."""
        template = "is a subrecipe"
        level = logging.DEBUG

    def __init__(self, scanner: Scanner, always=False) -> None:
        super().__init__(scanner)
        self.always_exclude = always

    async def apply(self, recipe: Recipe) -> None:
        is_subrecipe = recipe.reldir.strip("/").count("/") > 0
        enabled = self.is_enabled(recipe) == True
        if is_subrecipe and not (enabled and not self.always_exclude):
            raise self.IsSubRecipe(recipe)


class ExcludeDisabled(Filter, AutoBumpConfigMixin):
    """Exclude recipes disabled via config"""

    class IsDisabled(EndProcessingItem):
        """This recipe was explicitly disabled"""
        template = "is disabled for autobump"

    async def apply(self, recipe: Recipe) -> None:
        enabled = self.is_enabled(recipe)
        if not enabled and enabled is not None:
            raise self.IsDisabled(recipe)


class ExcludeBlacklisted(Filter):
    """Exclude blacklisted recipes"""

    class Blacklisted(EndProcessingItem):
        """This recipe has been blacklisted (fails to build, see blacklist file)"""
        template = "is blacklisted"
        level = logging.DEBUG

    def __init__(self, scanner: Scanner, recipe_base: str, config: Dict) -> None:
        super().__init__(scanner)
        self.blacklists = config.get('blacklists')
        self.blacklisted = utils.get_blacklist(config, recipe_base)
        logger.warning("Excluding %i blacklisted recipes", len(self.blacklisted))

    def get_info(self) -> str:
        return (super().get_info() +
                f": {', '.join(self.blacklists)} / {len(self.blacklisted)} recipes")

    async def apply(self, recipe: Recipe) -> None:
        if recipe.reldir in self.blacklisted:
            raise self.Blacklisted(recipe)


class ExcludeDependencyPending(Filter):
    """Exclude recipes depending on packages in need of update"""

    class DependencyPending(EndProcessingItem):
        """A dependency of this recipe is pending rebuild"""
        template = "deferred pending rebuild of dependencies: %s"

    def __init__(self, scanner: Scanner, dag: nx.DiGraph) -> None:
        self.scanner = scanner
        self.dag = dag

    async def apply(self, recipe: Recipe) -> None:
        pending_deps = [
            dep for dep in nx.ancestors(self.dag, recipe)
            if dep.is_modified()
        ]
        if pending_deps:
            msg =  ", ".join(str(x) for x in pending_deps)
            raise self.DependencyPending(recipe, msg)


class CheckPinning(Filter):
    """Bump recipes in need of rebuild after pinning changes"""

    def __init__(self, scanner: Scanner) -> None:
        self.scanner = scanner
        self.build_config = utils.load_conda_build_config()

    @staticmethod
    def match_version(spec, version):
        """Check if **version** satisfies **spec**

        >>> match_version('>1.2,<1.3.0a0', '1.2.1')
        True

        Args:
        spec: The version range specification
        version: The version to test against the spec
        Returns:
        True if the spec is satisfied by the version.
        """
        mspec = MatchSpec(version=spec.replace(" ", ""))
        return mspec.match({'name': '', 'build': '', 'build_number': 0,
                            'version': version})

    async def apply(self, recipe: Recipe) -> None:
        reason = await self.scanner.run_sp(
            self._sp_apply,
            (self.build_config, recipe)
        )
        if reason:
            recipe.data['pinning'] = reason
            new_buildno = recipe.build_number + 1
            logger.info("%s needs rebuild. Bumping buildnumber to %i", recipe, new_buildno)
            recipe.reset_buildnumber(new_buildno)
            recipe.render()

    @classmethod
    def _sp_apply(cls, data) -> None:
        config, recipe = data
        status, recipe = update_pinnings.check(recipe, build_config=config, keep_metas=True)
        if status.needs_bump():
            metas = recipe.conda_render(config=config)
            reason = cls.find_reason(recipe, metas)
        else:
            reason = None
        recipe.conda_release()
        return reason

    @classmethod
    def find_reason(cls, recipe, metas):
        # Decypher variants:
        pinnings = {}
        for variant in metas:
            variant0 = variant[0]
            for var in variant0.get_used_vars():
                pinnings.setdefault(var, set()).add(variant0.config.variant[var])
        variants = {k: v for k, v in pinnings.items() if len(v) > 1}
        if variants:
            logger.error("%s has variants: %s", recipe, variants)

        # Extend incomplete pinned versions
        # This is really only necessary because conda-forge pins zlib as 1.2, which
        # doesn't exist and needs to be extended to 1.2.11.
        resolved_vers = {}
        for var, vers in pinnings.items():
            avail_vers = RepoData().get_package_data('version', name=var)
            if avail_vers:
                resolved_vers[var] = list(set(
                    avs for avs in list(set(avail_vers))
                    for pvs in vers
                    if avs.startswith(pvs)))
            else:
                resolved_vers[var] = vers

        causes = {}
        # Iterate over extant builds for this recipe at this version and build number
        # It's one for noarch, two if osx and linux are built, more if we have
        # variant pins such as for python.
        package_data = RepoData().get_package_data(['build', 'depends', 'platform'],
                                                   name=recipe.name,
                                                   version=recipe.version,
                                                   build_number=recipe.build_number)
        for _build_id, package_deps, _platform in package_data:
            for item in package_deps:
                package, _, constraint = item.partition(" ")
                if not constraint or package not in pinnings:
                    continue
                if any(cls.match_version(constraint, version)
                       for version in resolved_vers[package]):
                    continue
                causes.setdefault(package, set()).add(
                    f"Pin `{package} {','.join(pinnings[package])}` not within `{constraint}`"
                )

        if not causes:
            compiler_pins = [i for k, v in pinnings.items() for i in v if 'compiler' in k]
            if compiler_pins:
                return {'compiler': set([f"Recompiling with {' / '.join(compiler_pins)}"])}
        return causes
        # must return not None!


class UpdateVersion(Filter, AutoBumpConfigMixin):
    """Scan upstream for new releases and update recipe

    - In the most simple case, a package has a single URL which also indicates the version
    - Recipes may have alternative download locations
      => Update to newest available, disable others as comment
    - Recipes may have multiple sources
      => Ignore URLs not matching main recipe version

    stages:
     1. select hoster based on source URL
     2. hoster determines releases page url
     3. fetch url
     4. hoster extracts (link,version) pairs
     5. select newest
     6. update sources
    """

    class Metapackage(EndProcessingItem):
        """This recipe only builds a meta package - it has no upstream sources."""
        template = "builds a meta package (recipe has no sources)"

    class UpToDate(EndProcessingItem):
        """This recipe appears to be up to date!"""
        template = "is up to date"
        level = logging.DEBUG

    class UpdateVersionFailure(EndProcessingItem):
        """This recipe did not show the expected version number after updating.

        Something probably went wrong trying to replace the version number in the
        meta.yaml.
        """
        template = "could not be updated from %s to %s"

    class NoUrlInSource(EndProcessingItem):
        """This recipe has a source without an URL.

        Most likely, this is due to a git-url.
        """
        template = "has no URL in source %i"

    class NoRecognizedSourceUrl(EndProcessingItem):
        """None of the source URLs in this recipe were recognized."""
        template = "has no URL in source %i recognized by any Hoster class"
        level = logging.DEBUG

    class UrlNotVersioned(EndProcessingItem):
        """This recipe has an URL unaffected by the version change.
        the recipe"""
        template = "has URL not modified by version change"

    class NoReleases(EndProcessingItem):
        """No releases at all were found for this recipe.

        This is unusual - something probably went wrong finding releases for
        the source urls in this recipe.
        """
        template = "has no releases?!"

    def __init__(self, scanner: Scanner, hoster_factory,
                 unparsed_file: Optional[str] = None) -> None:
        super().__init__(scanner)
        #: output file name for unparsed urls
        self.unparsed_urls: List[str] = []
        #: output file name for failed urls
        self.unparsed_file = unparsed_file
        #: function selecting hoster
        self.hoster_factory = hoster_factory
        #: conda build config
        self.build_config: conda_build.config.Config = \
            utils.load_conda_build_config()

    def finalize(self) -> None:
        """Save unparsed urls to file and print stats to log"""
        stats: Counter = Counter()
        for url in self.unparsed_urls:
            parsed = urlparse(url)
            stats[parsed.scheme] += 1
            stats[parsed.netloc] += 1
        logger.info("Unrecognized URL stats:")
        for key, value in stats.most_common():
            logger.info("%s: %i", key, value)

        if self.unparsed_urls and self.unparsed_file:
            with open(self.unparsed_file, "w") as out:
                out.write("\n".join(self.unparsed_urls))

    async def apply(self, recipe: Recipe) -> None:
        logger.debug("Checking for updates to %s - %s", recipe, recipe.version)

        # scan for available versions
        versions = await self.get_version_map(recipe)
        # (too slow) conflicts = self.check_version_pin_conflict(recipe, versions)

        # select apropriate most current version
        latest = self.select_version(recipe.version, versions.keys())

        # add data for respective versions to recipe and recipe.orig
        recipe.version_data = versions[latest] or {}
        if recipe.orig.version in versions:
            recipe.orig.version_data = versions[recipe.orig.version] or {}
        else:
            recipe.orig.version_data = {}

        # exit here if we found no new version
        if VersionOrder(latest) == VersionOrder(recipe.version):
            return

        # Update `url:`s without Jinja expressions (plain text)
        for fname in versions[latest]:
            recipe.replace(fname, versions[latest][fname]['link'], within=["source"])

        # Update the version number itself. This will also usually update
        # `url:`s expressed with `{{version}}` tags.
        if not recipe.replace(recipe.version, latest, within=["package"]):
            # allow changes between dash/dot/underscore
            if recipe.replace(recipe.version, latest, within=["package"], with_fuzz=True):
                logger.warning("Recipe %s: replaced version with fuzz", recipe)

        recipe.reset_buildnumber()
        recipe.render()

        # Verify that the rendered recipe has the right version number
        if VersionOrder(recipe.version) != VersionOrder(latest):
            raise self.UpdateVersionFailure(recipe, recipe.orig.version, latest)

        # Verify that every url was modified
        for src, osrc in zip(ensure_list(recipe.meta['source']),
                             ensure_list(recipe.orig.meta['source'])):
            for url, ourl in zip(ensure_list(src['url']),
                                 ensure_list(osrc['url'])):
                if url == ourl:
                    raise self.UrlNotVersioned(recipe)

    async def get_version_map(self, recipe: Recipe):
        """Scan all source urls"""

        sources = recipe.meta.get("source")
        if not sources:
            raise self.Metapackage(recipe)

        if isinstance(sources, Sequence):
            source_iter = iter(sources)
            versions = await self.get_versions(recipe, next(source_iter), 0)
            for num, source in enumerate(source_iter):
                add_versions = await self.get_versions(recipe, source, num+1)
                for vers, files in add_versions.items():
                    for fname, data in files.items():
                        versions[vers][fname] = data
        else:
            versions = await self.get_versions(recipe, sources, 0)

        if not versions:
            raise self.NoReleases(recipe)
        return versions

    async def get_versions(self, recipe: Recipe, source: Mapping[Any, Any],
                           source_idx: int):
        """Select hosters and retrieve versions for this source"""
        urls = source.get("url")
        if not urls:
            raise self.NoUrlInSource(recipe, source_idx+1)
        if isinstance(urls, str):
            urls = [urls]

        version_map: Dict[str, Dict[str, Any]] = defaultdict(dict)
        for url in urls:
            config = self.get_config(recipe)
            hoster = self.hoster_factory(url, config.get("override", {}))
            if not hoster:
                self.unparsed_urls += [url]
                continue
            logger.debug("Scanning with %s", hoster.__class__.__name__)
            try:
                versions = await hoster.get_versions(self.pipeline.req, recipe.orig.version)
                for match in versions:
                    match['hoster'] = hoster
                    version_map[match["version"]][url] = match
            except ClientResponseError as exc:
                logger.debug("HTTP %s when getting %s", exc, url)

        if not version_map:
            raise self.NoRecognizedSourceUrl(recipe, source_idx+1)

        return version_map

    @staticmethod
    def select_version(current: str, versions: Sequence[str]) -> str:
        """Chooses the most recent, acceptable version out of **versions**

        - must be newer than current (as defined by conda VersionOrder)

        - may only be a pre-release if current is pre-release (as
          defined by parse_version)

        - may only be "Legacy" (=strange) if current is Legacy (as
          defined by parse_version)
        """
        current_version = parse_version(current)
        current_is_legacy = isinstance(current_version, LegacyVersion)
        latest_vo = VersionOrder(current)
        latest = current
        for vers in versions:
            if "-" in vers:  # ignore versions with local (FIXME)
                continue
            vers_version = parse_version(vers)
            # allow prerelease only if current is prerelease
            if vers_version.is_prerelease and not current_version.is_prerelease:
                continue
            # allow legacy only if current is legacy
            vers_is_legacy = isinstance(vers_version, LegacyVersion)
            if vers_is_legacy and not current_is_legacy:
                continue
            # using conda version order here as that's what will be
            # used by the package manager
            vers_vo = VersionOrder(vers)
            if vers_vo > latest_vo:
                latest_vo = vers_vo
                latest = vers

        return latest

    def check_version_pin_conflict(self, recipe: Recipe,
                                   versions: Dict[str, Any]) -> None:
        """Find items in **versions** conflicting with pins

        Example:
          If ggplot 7.0 needs r-base 4.0, but our pin is 3.5.1, it conflicts

        TODO: currently, this only logs an error
        """
        variants = conda_build.variants.get_package_variants(
            recipe.path, self.build_config)

        def check_pins(depends):
            for pkg, spec in depends:
                norm_pkg = pkg.replace("-", "_")
                try:
                    mspec = MatchSpec(version=spec.replace(" ", ""))
                except conda.exceptions.InvalidVersionSpecError:
                    logger.error("Recipe %s: invalid upstream spec %s %s",
                                 recipe, pkg, repr(spec))
                    continue
                if norm_pkg in variants[0]:
                    for variant in variants:
                        if not mspec.match({'name': '', 'build': '', 'build_number': '0',
                                            'version': variant[norm_pkg]}):
                            logger.error("Recipe %s: %s %s conflicts pins",
                                         recipe, pkg, spec)

        for files in versions.values():
            for data in files.values():
                depends = data.get('depends')
                if depends:
                    check_pins(depends.items())


class FetchUpstreamDependencies(Filter):
    """Fetch additional upstream dependencies (PyPi)

    This currently only affects PyPi. Dependencies for Python packages are
    determined by ``setup.py`` at installation time and need not be static
    in many cases (there is work to change this going on).
    """
    def __init__(self, scanner: Scanner) -> None:
        super().__init__(scanner)
        #: conda build config
        self.build_config: conda_build.config.Config = \
            utils.load_conda_build_config()

    async def apply(self, recipe: Recipe) -> None:
        await asyncio.gather(*[
            data["hoster"].get_deps(self.pipeline, self.build_config,
                                    recipe.name, data)
            for r in (recipe, recipe.orig)
            for fn, data in r.version_data.items()
            if "depends" not in data
            and "hoster" in data
            and hasattr(data["hoster"], "get_deps")
        ])


class UpdateChecksums(Filter):
    """Update source checksums

    If the recipe has had a version change, all sources will be downloaded,
    the checksums calculated and the recipe updated accordingly.

    - Automatically moves packages from md5 to sha256.
    - Aborts processing the recipe
      - if the checksum did not change
      - if there were no valid URLs
      - if checksums do not match among alternate URLs for a source

    Args:
      failed_file: Store the list of URLs for which downloading failed to this
                   file upon pipeline completion.

    FIXME:
      Should ignore sources for which no change has been made.
    """

    class NoValidUrls(EndProcessingItem):
        """Failed to download any file for a source to generate new checksum"""
        template = "has no valid urls in source %i"

    class SourceUrlMismatch(EndProcessingItem):
        """The URLs in a source point to different files after update"""
        template = "has mismatching cheksums for alternate URLs in source %i"

    class ChecksumReplaceFailed(EndProcessingItem):
        """The checksum could not be updated after version bump"""
        template = "- failed to replace checksum"

    class ChecksumUnchanged(EndProcessingItem):
        """The checksum did not change after version bump"""
        template = "had no change to checksum after update?!"

    def __init__(self, scanner: Scanner,
                 failed_file: Optional[str] = None) -> None:
        super().__init__(scanner)
        #: failed urls - for later inspection
        self.failed_urls: List[str] = []
        #: unparsed urls - for later inspection
        self.failed_file = failed_file

    def finalize(self):
        """Store list of URLs that could not be downloaded"""
        if self.failed_urls:
            logger.warning("Encountered %i download failures while computing checksums",
                           len(self.failed_urls))
        if self.failed_urls and self.failed_file:
            with open(self.failed_file, "w") as out:
                out.write("\n".join(self.failed_urls))

    async def apply(self, recipe: Recipe) -> None:
        if recipe.is_modified() and recipe.build_number == 0:
            # FIXME: not the best way to test this

            sources = recipe.meta["source"]
            logger.info("Updating checksum for %s %s", recipe, recipe.version)
            if isinstance(sources, Mapping):
                sources = [sources]
            for source_idx, source in enumerate(sources):
                await self.update_source(recipe, source, source_idx)
            recipe.render()

    async def update_source(self, recipe: Recipe, source: Mapping, source_idx: int) -> None:
        """Updates one source

        Each source has its own checksum, but all urls in one source must have
        the same checksum (if the link is available).

        We don't fail if the link is not available as cargo-port will only update
        after the recipe was built and uploaded
        """
        checksum_type = "none"
        for checksum_type in ("sha256", "sha1", "md5"):
            checksum = source.get(checksum_type)
            if checksum:
                break
        else:
            logger.error("Recipe %s has no checksum", recipe)
            return
        if checksum_type != "sha256":
            logger.info("Recipe %s had checksum type %s", recipe, checksum_type)
            if not recipe.replace(checksum_type, "sha256"):
                raise RuntimeError("Failed to replace checksum type?")

        urls = ensure_list(source["url"])
        new_checksums = set()
        for url_idx, url in enumerate(urls):
            try:
                new_checksums.add(
                    await self.pipeline.req.get_checksum_from_url(
                        url, f"{recipe} [{source_idx}.{url_idx}]")
                )
            except ClientResponseError as exc:
                logger.info("Recipe %s: HTTP %s while downloading url %i",
                            recipe, exc.code, url_idx)
                self.failed_urls += ["\t".join((str(exc.code), url))]

        if not new_checksums:
            raise self.NoValidUrls(recipe, source_idx)
        if len(new_checksums) > 1:
            logger.error("Recipe %s source %i: checksum mismatch between alternate urls - %s",
                         recipe, source_idx, new_checksums)
            raise self.SourceUrlMismatch(recipe, source_idx)

        new_checksum = new_checksums.pop()
        if checksum == new_checksum and not recipe.on_branch:
            raise self.ChecksumUnchanged(recipe)
        if not recipe.replace(checksum, new_checksum):
            raise self.ChecksumReplaceFailed(recipe)


class GitFilter(Filter):
    """Base class for `Filter` types needing access to the git repo

    Arguments:
       scanner: Scanner we are called from
       git_handler: Instance of GitHandler for repo access
    """

    branch_prefix = "bump/"

    def __init__(self, scanner: Scanner, git_handler: "GitHandler") -> None:
        super().__init__(scanner)
        #: The `GitHandler` class for accessing repo
        self.git = git_handler

    @classmethod
    def branch_name(cls, recipe: Recipe) -> str:
        """Render branch name from recipe

        - Replace dashes with underscores (GitPython does not like dash)
        - Replace slashes with ``.d/`` slash as Git will use directories when separating
          parts with slashes, so ``bump/toolx`` cannot be a branch at the same time as
          ``bump/toolx/1.2.x``.
          Note: this will break if we have ``recipe/x`` and ``recipe/x.d`` in the repo.
        """
        return f"{cls.branch_prefix}{recipe.reldir.replace('-', '_').replace('/', '.d/')}"

    # placate pylint by reiterating abstract method
    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> None:
        pass


class ExcludeNoActiveUpdate(GitFilter):
    """Exclude recipes not currently undergoing an update

    Requires that the recipes are loaded from git - recipes with active
    updates are those for which a branch with commits newer than master
    exists (which is checked by GitLoadRecipe).
    """
    class NoActiveUpdate(EndProcessingItem):
        """Recipe is not currently being updated"""
        template = "is not currently being updated"
        level = logging.DEBUG

    async def apply(self, recipe: Recipe) -> None:
        branch_name = self.branch_name(recipe)
        if not self.git.get_remote_branch(branch_name):
            raise self.NoActiveUpdate(recipe)


class LoadRecipe(Filter):
    """Load the recipe from the filesystem"""
    def __init__(self, scanner: Scanner) -> None:
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(64)

    async def apply(self, recipe: Recipe) -> None:
        async with self.sem, \
                   aiofiles.open(recipe.path, encoding="utf-8") as fdes:
            recipe_text = await fdes.read()
        recipe.load_from_string(recipe_text)
        recipe.set_original()


class GitLoadRecipe(GitFilter):
    """Load recipe from git (honoring active branches)

    We have three locations for the recipe:
    1. master in upstream remote repo
    2. auto_update_xxx in local repo
    3. auto_update_xxx in origin remote repo

    If the remote branch exists and is newer than master, we either have an active update
    that has not been merged yet, or an update for which the PR has been closed. We
    work from there so that we don't recreate the "same" update.

    - Always remove the local branch - it's ephemereal.
    - If there is a remote branch that has not been superceded by master, work from there.
    - Otherwise load master
    """

    async def apply(self, recipe: Recipe) -> None:
        branch_name = self.branch_name(recipe)
        remote_branch = self.git.get_remote_branch(branch_name)
        local_branch = self.git.get_local_branch(branch_name)
        master_branch = self.git.get_local_branch('master')

        if local_branch:
            logger.debug("Recipe %s: removing local branch %s", recipe, branch_name)
            self.git.delete_local_branch(local_branch)

        logger.debug("Recipe %s: loading from master", recipe)
        recipe_text = await self.pipeline.run_io(
            self.git.read_from_branch, master_branch, recipe.path)
        recipe.load_from_string(recipe_text)
        recipe.set_original()

        if remote_branch:
            if await self.git.branch_is_current(remote_branch, recipe.dir):
                logger.info("Recipe %s: updating from remote %s", recipe, branch_name)
                recipe_text = await self.pipeline.run_io(self.git.read_from_branch,
                                                         remote_branch, recipe.path)
                recipe.load_from_string(recipe_text)
                await self.pipeline.run_io(self.git.create_local_branch, branch_name)
                recipe.on_branch = True
            else:
                # Note: If a PR still exists for this, it is silently closed by deleting
                #       the branch.
                logger.info("Recipe %s: deleting outdated remote %s", recipe, branch_name)
                await self.pipeline.run_io(self.git.delete_remote_branch, branch_name)

class WritingFilter:
    class NoChanges(EndProcessingItem):
        """Recipe had no changes after applying updates"""
        template = "had no changes"


class WriteRecipe(Filter, WritingFilter):
    """Write recipe to filesystem"""
    def __init__(self, scanner: Scanner) -> None:
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(64)

    async def apply(self, recipe: Recipe) -> None:
        if not recipe.is_modified():
            raise self.NoChanges(recipe)
        async with self.sem, \
                   aiofiles.open(recipe.path, "w", encoding="utf-8") as fdes:
            await fdes.write(recipe.dump())


class GitWriteRecipe(GitFilter, WritingFilter):
    """Write recipe to per-recipe git branch"""

    async def apply(self, recipe: Recipe) -> None:
        if not recipe.is_modified():
            raise self.NoChanges(recipe)

        branch_name = self.branch_name(recipe)
        changed = False
        async with self.git.lock_working_dir:
            self.git.prepare_branch(branch_name)
            async with aiofiles.open(recipe.path, "w",
                                     encoding="utf-8") as fdes:
                await fdes.write(recipe.dump())
            if recipe.version != recipe.orig.version:
                msg = f"Update {recipe} to {recipe.version}"
            elif recipe.build_number != recipe.orig.build_number:
                msg = f"Bump {recipe} buildnumber"
            else:
                msg = f"Update {recipe}"
            changed = self.git.commit_and_push_changes([recipe.path], branch_name, msg)
        if changed:
            # CircleCI appears to have problems picking up on our PRs. Let's wait
            # a while before we create the PR, so the pushed branch has time to settle.
            await asyncio.sleep(10)  # let push settle before going on
        elif not recipe.on_branch:
            raise self.NoChanges(recipe)


class CreatePullRequest(GitFilter):
    """Create or Update PR on GitHub"""

    class UpdateInProgress(EndProcessingItem):
        """The recipe has an active update PR"""
        template = "has update in progress"

    class UpdateRejected(EndProcessingItem):
        """This update has been rejected previously on Github

        A PR created by Autobump for this recipe and this version
        already exists on Github and has been closed. We take this as
        indication that the update should not be repeated

        """
        template = "had latest updated rejected manually"

    class FailedToCreatePR(EndProcessingItem):
        """Something went wrong trying to create a new PR on Github."""
        template = "had failure in PR create"

    def __init__(self, scanner: Scanner, git_handler: "GitHandler",
                 github_handler: "GitHubHandler") -> None:
        super().__init__(scanner, git_handler)
        self.ghub = github_handler

    async def async_init(self):
        """Create gidget GithubAPI object from session"""
        await self.ghub.login(self.pipeline.req.session, self.pipeline.req.USER_AGENT)
        await asyncio.sleep(1)  # let API settle

    @staticmethod
    def render_deps_diff(recipe):
        """Renders a "diff" of the recipes upstream dependencies.

        This relies on the 'depends' data structure in the recipe's
        ``version_data``. This structure is expected to be a dict with
        two keys 'host' and 'run', each of which contain dict of
        package to version dependency mappings. The 'depends' data can
        be created by the **hoster** (currently done by CPAN and CRAN)
        or filled in later by the `FetchUpstreamDependencies` filter
        (currently for PyPi).
        """
        diffset: Dict[str, Set[str]] = {'host': set(), 'run': set()}
        if not recipe.version_data:
            logger.debug("Recipe %s: dependency diff not rendered (no version_data)", recipe)
        for fname in recipe.version_data:
            if fname not in recipe.orig.version_data:
                logger.debug("Recipe %s: dependency diff not rendered (no orig.version_data)",
                             recipe)
                continue
            new = recipe.version_data[fname].get('depends')
            orig = recipe.orig.version_data[fname].get('depends')
            if not new or not orig:
                logger.debug("Recipe %s: dependency diff not rendered (no depends in version_data)",
                             recipe)
                continue
            for kind in ('host', 'run'):
                deps: Set[str] = set()
                deps.update(new[kind].keys())
                deps.update(orig[kind].keys())
                for dep in deps:
                    if dep not in new[kind]:
                        diffset[kind].add("-   - {} {}".format(dep, orig[kind][dep]))
                    elif dep not in orig[kind]:
                        diffset[kind].add("+   - {} {}".format(dep, new[kind][dep]))
                    elif orig[kind][dep] != new[kind][dep]:
                        diffset[kind].add("-   - {dep} {}\n"
                                          "+   - {dep} {}".format(orig[kind][dep], new[kind][dep],
                                                                  dep=dep))
        text = ""
        for kind, lines in diffset.items():
            if lines:
                text += "  {}:\n".format(kind)
                text += "\n".join(sorted(lines, key=lambda x: x[1:])) + "\n"
        if not text:
            logger.debug("Recipe %s: dependency diff not rendered (all good)", recipe)
        return text

    @staticmethod
    def get_github_author(recipe) -> Optional[str]:
        """Fetches upstream Github account name if applicable

        For recipes with upstream sources hosted on Github, we can extract
        the account name from the source URL, so that we can add an @mention
        notifying the upstream author of the update.
        """
        if not recipe.version_data:
            return None
        for ver in recipe.version_data.values():
            if 'hoster' in ver and ver['hoster'].__class__.__name__.startswith('Github'):
                return ver['vals']['account']
        return None

    async def apply(self, recipe: Recipe) -> None:
        if not recipe.is_modified():
            return
        branch_name = self.branch_name(recipe)
        author = self.get_github_author(recipe)

        if recipe.version != recipe.orig.version:
            template_name = "autobump_bump_version_pr.md"
        else:
            template_name = "autobump_update_pinning_pr.md"
        template = utils.jinja.get_template(template_name)

        context = template.new_context({
            'r': recipe,
            'recipe_relurl': self.ghub.get_file_relurl(recipe.dir, branch_name),
            'author': author,
            'author_is_member': await self.ghub.is_member(author),
            'dependency_diff': self.render_deps_diff(recipe),
            'version': __version__
        })

        labels = (''.join(template.blocks['labels'](context))).splitlines()
        title = ''.join(template.blocks['title'](context)).replace('\n',' ')
        body = template.render(context)

        # check if we already have an open PR (=> update in progress)
        pullreqs = await self.ghub.get_prs(from_branch=branch_name, from_user="bioconda")
        if pullreqs:
            if len(pullreqs) > 1:
                logger.error("Multiple PRs updating %s: %s",
                             recipe,
                             ", ".join(str(pull['number']) for pull in pullreqs))
            for pull in pullreqs:
                logger.debug("Found PR %i updating %s: %s",
                             pull["number"], recipe, pull["title"])
            # update the PR if title or body changed
            pull = pullreqs[0]
            if body == pull["body"]:
                body = None
            if title == pull["title"]:
                title = None
            if not (body is None and title is None):
                if await self.ghub.modify_issue(number=pull['number'], body=body, title=title):
                    logger.info("Updated PR %i updating %s to %s",
                                pull['number'], recipe, recipe.version)
                else:
                    logger.error("Failed to update PR %i with title=%s and body=%s",
                                 pull['number'], title, body)
            else:
                logger.debug("Not updating PR %i updating %s - no changes",
                             pull['number'], recipe)

            raise self.UpdateInProgress(recipe)

        # check for matching closed PR (=> update rejected)
        pullreqs = await self.ghub.get_prs(from_branch=branch_name, state=self.ghub.STATE.closed)
        if any(recipe.version in pull['title'] for pull in pullreqs):
            raise self.UpdateRejected(recipe)

        # finally, create new PR
        pull = await self.ghub.create_pr(title=title,
                                         from_branch=branch_name,
                                         body=body)
        if not pull:
            raise self.FailedToCreatePR(recipe)

        # set labels (can't do that in create_pr as they are part of issue API)
        await self.ghub.modify_issue(number=pull['number'], labels=labels)

        logger.info("Created PR %i: %s", pull['number'], title)


class MaxUpdates(Filter):
    """Terminate pipeline after **max_updates** recipes have been updated."""
    def __init__(self, scanner: Scanner, max_updates: int = 0) -> None:
        super().__init__(scanner)
        self.max_updates = max_updates
        self.count = 0
        logger.warning("Will exit after %s updated recipes", max_updates)

    def get_info(self) -> str:
        return super().get_info().replace('**max_updates**', str(self.max_updates))

    async def apply(self, recipe: Recipe) -> None:
        if not recipe.is_modified():
            return
        self.count += 1
        if self.max_updates and self.count == self.max_updates:
            logger.warning("Reached update limit %s", self.count)
            raise EndProcessing()
