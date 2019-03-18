"""Updates packages when new upstream releases become available

Overview:

- The `Scanner` initializes the `asyncio` loop and for each recipe,
  loads the ``meta.yaml`` using `Recipe` and executes its `Filter`
  objects for each recipe.

- The `Recipe` handles reading, modification and writing of
   ``meta.yaml`` files.

- The filters `ExcludeSubrecipe` and `ExcludeOtherChannel` exclude
  recipes in sub folders and present in other channels as configured.

- The filter `UpdateVersion` determines available upstream verions
  using `Hoster` and its subclasses, selects the most recent,
  acceptable version and uses `Recipe` to replace

- The filter `UpdateChecksum` downloads the modified source URLs
  and updates the checksums for each source of a recipe.

- The filter `CommitToBranch` commits the changes made to each recipe
  to individual branches.

- The filter `WriteRecipe` (alternate to `CommitToBranch` simply
  writes changes to the current branch.

- The filter `CreateGithubPR` creates pull requests on GitHub for
  changes made to per-recipe-branches.

Rationale (for all those imports):

- We use `asyncio` because it allows us to "to something else" while
  we are waiting for one of the many remote servers to complete a
  request (or fail to). As a consequence, we use `aiohttp` for HTTP
  requests, `aiofiles` for file I/O and `gidget` to access the GitHub
  API. Retrying is handled using decorators from `backoff`.

- We use `ruamel.yaml` to know where in a ``.yaml`` file a value is
  defined. Ideally, we would extend its round-trip type to handle the
  `# [exp]` line selectors and at least simple parts of Jinja2
  template expansion.

"""

import abc
import asyncio
import logging
import os
import random

from collections import defaultdict, Counter

from urllib.parse import urlparse
from typing import (Any, Dict, Iterator, List, Mapping, Optional, Sequence,
                    Set, Tuple, TYPE_CHECKING)

import aiofiles
from aiohttp import ClientResponseError
import yaml

import conda_build.variants
import conda_build.config
from conda.exports import MatchSpec, VersionOrder
import conda.exceptions

from pkg_resources import parse_version

from . import utils
from .utils import ensure_list
from .recipe import Recipe
from .async import AsyncFilter, AsyncPipeline, AsyncRequests, EndProcessingItem, EndProcessing

if TYPE_CHECKING:
    from .githandler import GitHandler
    from .githubhandler import AiohttpGitHubHandler, GitHubHandler

# pkg_resources.parse_version returns a Version or LegacyVersion object
# as defined in packaging.version. Since it's bundling it's own copy of
# packaging, the class it returns is not the same as the one we can import.
# So we cheat by having it create a LegacyVersion delibarately.
LegacyVersion = parse_version("").__class__  # pylint: disable=invalid-name


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class Scanner(AsyncPipeline[Recipe]):
    """Scans recipes and applies filters in asyncio loop

    Arguments:
      recipe_folder: location of recipe directories
      packages: glob pattern to select recipes
      config: config.yaml (unused)
    """
    def __init__(self, recipe_folder: str, packages: List[str],
                 cache_fn: str = None, max_inflight: int = 100,
                 status_fn: str = None) -> None:
        super().__init__(max_inflight)
        #: folder containing recipes
        self.recipe_folder: str = recipe_folder
        #: glob expressions
        self.packages: List[str] = packages
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
        res = super().run()
        logger.info("")
        logger.info("Recipe status statistics:")
        for key, value in self.stats.most_common():
            logger.info("%s: %s", key, value)
        logger.info("SUM: %i", sum(self.stats.values()))
        if self.status_fn:
            with open(self.status_fn, "w") as out:
                for entry in self.status:
                    out.write('\t'.join(entry)+"\n")
        return res

    def get_item_iterator(self) -> Iterator[Recipe]:
        """Return initial iterator over stub (unloaded) Recipes"""
        recipes = list(utils.get_recipes(self.recipe_folder, self.packages))
        random.shuffle(recipes)
        return (Recipe(recipe_dir, self.recipe_folder)
                for recipe_dir in recipes)

    async def _async_run(self) -> bool:
        """Runner within async loop"""
        async with self.req:
            return await super()._async_run()

    async def process(self, recipe: Recipe) -> bool:
        """Applies the filters to a recipe"""
        try:
            if await super().process(recipe):
                self.stats["Updated"] += 1
                return True
            return False
        except EndProcessingItem as recipe_error:
            self.stats[recipe_error.name] += 1
            self.status.append((recipe.reldir, recipe_error.name))
            return True


class Filter(AsyncFilter[Recipe]):
    """Filter for Scanner - class exists primarily to silence mypy"""
    pipeline: Scanner

    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> Recipe:
        """Process a recipe. Returns False if processing should stop"""


class ExcludeOtherChannel(Filter):
    """Filters recipes matching packages in other **channels**"""

    class OtherChannel(EndProcessingItem):
        """This recipe builds one or more packages that are also present
        in at least one other channel"""
        template = "builds package found in other channel(s)"
        level = logging.DEBUG

    def __init__(self, scanner: Scanner, channels: Sequence[str],
                 cache: str) -> None:
        super().__init__(scanner)
        logger.info("Loading package lists for %s", channels)
        repo = utils.RepoData()
        if cache:
            repo.set_cache(cache)
        self.other = set(repo.get_package_data('name', channels=channels))

    async def apply(self, recipe: Recipe) -> Recipe:
        if any(package in self.other
               for package in recipe.package_names):
            raise self.OtherChannel(recipe)
        return recipe


class ExcludeSubrecipe(Filter):
    """Filters sub-recipes

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

    async def apply(self, recipe: Recipe) -> Recipe:
        is_subrecipe = recipe.reldir.strip("/").count("/") > 0
        enabled = recipe.config.get("enable", False)
        if is_subrecipe and not (enabled and not self.always_exclude):
            raise self.IsSubRecipe(recipe)
        return recipe


class ExcludeBlacklisted(Filter):
    """Filters blacklisted recipes"""

    class Blacklisted(EndProcessingItem):
        """This recipe has been blacklisted (fails to build, see blacklist file)"""
        template = "is blacklisted"
        level = logging.DEBUG

    def __init__(self, scanner, config_fn: str) -> None:
        super().__init__(scanner)
        with open(config_fn, "r") as config_fdes:
            config = yaml.load(config_fdes)
        blacklists = [os.path.join(os.path.dirname(config_fn), bl)
                      for bl in config['blacklists']]
        self.blacklisted = utils.get_blacklist(blacklists, scanner.recipe_folder)
        logger.warning("Excluding %i blacklisted recipes", len(self.blacklisted))

    async def apply(self, recipe: Recipe) -> Recipe:
        if recipe.reldir in self.blacklisted:
            raise self.Blacklisted(recipe)
        return recipe


class UpdateVersion(Filter):
    """Checks for updates to a recipe

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
     4. update sources
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

    def finalize(self):
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

    async def apply(self, recipe: Recipe):
        logger.debug("Checking for updates to %s - %s", recipe, recipe.version)

        # scan for available versions
        versions = await self.get_version_map(recipe)
        # (too slow) conflicts = self.check_version_pin_conflict(recipe, versions)

        # select apropriate most current version
        latest = self.select_version(recipe.version, versions.keys())

        # add data for respective versions to recipe and recipe.orig
        recipe.version_data = versions[latest]
        if recipe.orig.version in versions:
            recipe.orig.version_data = versions[recipe.orig.version]
        else:
            recipe.orig.version_data = {}

        # check if the recipe is up to date
        if VersionOrder(latest) == VersionOrder(recipe.version):
            if not recipe.on_branch:
                raise self.UpToDate(recipe)

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

        return recipe

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
            hoster = self.hoster_factory(url, recipe.config.get("override", {}))
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
    """Fetch requirements from upstream where possible

    This currently only affects PyPi. Dependencies for Python packages are
    determined by ``setup.py`` at installation time and need not be static
    in many cases (there is work to change this going on).
    """
    def __init__(self, scanner: Scanner) -> None:
        super().__init__(scanner)
        #: conda build config
        self.build_config: conda_build.config.Config = \
            utils.load_conda_build_config()

    async def apply(self, recipe: Recipe) -> Recipe:
        await asyncio.gather(*[
            data["hoster"].get_deps(self.pipeline, self.build_config,
                                    recipe.name, data)
            for r in (recipe, recipe.orig)
            for fn, data in r.version_data.items()
            if "depends" not in data
            and "hoster" in data
            and hasattr(data["hoster"], "get_deps")
        ])
        return recipe


class UpdateChecksums(Filter):
    """Download upstream source files, recompute checksum and update Recipe"""

    class NoValidUrls(EndProcessingItem):
        """Failed to download any file for a source to generate new checksum"""
        template = "has no valid urls in source %i"

    class SourceUrlMismatch(EndProcessingItem):
        """The URLs in a source point to different files after update"""
        template = "has urls in source %i pointing to different files"

    class ChecksumReplaceFailed(EndProcessingItem):
        """The checksum could not be updated after version bump"""
        template = ": failed to replace checksum"

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

    async def apply(self, recipe: Recipe) -> Recipe:
        sources = recipe.meta["source"]
        logger.info("Updating checksum for %s %s", recipe, recipe.version)
        if isinstance(sources, Mapping):
            sources = [sources]
        for source_idx, source in enumerate(sources):
            await self.update_source(recipe, source, source_idx)
        recipe.render()
        return recipe

    async def update_source(self, recipe: Recipe, source: Mapping, source_idx: int) -> None:
        """Updates one source

        Each source has its own checksum, but all urls in one source must have
        the same checksum (if the link is available).

        We don't fail if the link is not available as cargo-port will only update
        after the recipe was built and uploaded.
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
    """Base class for `Filter`s needing access to the git repo

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
    def branch_name(cls, recipe):
        """Render branch name from recipe

        - Replace dashes with underscores (GitPython does not like dash)
        - Replace slashes with `.d/` slash as Git will use directories when separating
          parts with slashes, so `bump/toolx` cannot be a branch at the same time as
         `bump/toolx/1.2.x`.
          Note: this will break if we have `recipe/x` and `recipe/x.d` in the repo.
        """
        return f"{cls.branch_prefix}{recipe.reldir.replace('-', '_').replace('/', '.d/')}"

    # placate pylint by reiterating abstract method
    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> Recipe:
        pass


class ExcludeNoActiveUpdate(GitFilter):
    """Allows only recipes that already have an update active

    Requires that the recipes are loaded from git - recipes with active
    updates are those for which a branch with commits newer than master
    exists (which is checked by GitLoadRecipe).
    """
    class NoActiveUpdate(EndProcessingItem):
        """Recipe is not currently being updated"""
        template = "is not currently being updated"
        level = logging.DEBUG

    async def apply(self, recipe: Recipe) -> Recipe:
        branch_name = self.branch_name(recipe)
        if not self.git.get_remote_branch(branch_name):
            raise self.NoActiveUpdate(recipe)
        return recipe


class LoadRecipe(Filter):
    """Loads the Recipe from the filesystem"""
    def __init__(self, scanner: Scanner) -> None:
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(10)

    async def apply(self, recipe: Recipe) -> Recipe:
        async with self.sem, \
                   aiofiles.open(recipe.path, encoding="utf-8") as fdes:
            recipe_text = await fdes.read()
        recipe = await self.pipeline.run_sp(recipe.load_from_string, recipe_text)
        recipe.set_original()
        return recipe


class GitLoadRecipe(GitFilter):
    """Loads `Recipe` from git repo

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

    async def apply(self, recipe: Recipe) -> Recipe:
        branch_name = self.branch_name(recipe)
        remote_branch = self.git.get_remote_branch(branch_name)
        local_branch = self.git.get_local_branch(branch_name)

        if local_branch:
            logger.debug("Recipe %s: removing local branch %s", recipe, branch_name)
            self.git.delete_local_branch(local_branch)

        logger.debug("Recipe %s: loading from master", recipe)
        recipe_text = await self.pipeline.run_io(self.git.read_from_branch,
                                                 self.git.master, recipe.path)
        recipe = await self.pipeline.run_sp(recipe.load_from_string, recipe_text)
        recipe.set_original()

        if remote_branch:
            if await self.git.branch_is_current(remote_branch, recipe.dir):
                logger.info("Recipe %s: updating from remote %s", recipe, branch_name)
                recipe_text = await self.pipeline.run_io(self.git.read_from_branch,
                                                         remote_branch, recipe.path)
                recipe = await self.pipeline.run_sp(recipe.load_from_string, recipe_text)
                await self.pipeline.run_io(self.git.create_local_branch, branch_name)
                recipe.on_branch = True
            else:
                # Note: If a PR still exists for this, it is silently closed by deleting
                #       the branch.
                logger.info("Recipe %s: deleting outdated remote %s", recipe, branch_name)
                await self.pipeline.run_io(self.git.delete_remote_branch, branch_name)
        return recipe


class WriteRecipe(Filter):
    """Writes the Recipe to the filesystem"""
    def __init__(self, scanner: Scanner) -> None:
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(10)

    async def apply(self, recipe: Recipe) -> Recipe:
        async with self.sem, \
                   aiofiles.open(recipe.path, "w", encoding="utf-8") as fdes:
            await fdes.write(recipe.dump())
        return recipe


class GitWriteRecipe(GitFilter):
    """Writes `Recipe` to git repo"""

    class NoChanges(EndProcessingItem):
        """Recipe had no changes after applying updates"""
        template = "had no changes"

    async def apply(self, recipe: Recipe) -> Recipe:
        branch_name = self.branch_name(recipe)
        changed = False
        async with self.git.lock_working_dir:
            self.git.prepare_branch(branch_name)
            async with aiofiles.open(recipe.path, "w",
                                     encoding="utf-8") as fdes:
                await fdes.write(recipe.dump())
            msg = f"Update {recipe} to {recipe.version}"
            changed = self.git.commit_and_push_changes([recipe.path], branch_name, msg)
        if changed:
            # CircleCI appears to have problems picking up on our PRs. Let's wait
            # a while before we create the PR, so the pushed branch has time to settle.
            await asyncio.sleep(10)  # let push settle before going on
        elif not recipe.on_branch:
            raise self.NoChanges(recipe)
        return recipe


class CreatePullRequest(GitFilter):
    """Creates or Updates PR on GitHub"""

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
        ``version_data`. This structure is expected to be a dict with
        two keys 'host' and 'run', each of which contain dict of
        package to version dependency mappings. The 'depends' data can
        be created by the **hoster** (currently done by CPAN and CRAN)
        or filled in later by the `FetchUpstreamDependcies` filter
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
        for ver in recipe.version_data.values():
            if 'hoster' in ver and ver['hoster'].__class__.__name__.startswith('Github'):
                return ver['vals']['account']
        return None

    async def apply(self, recipe: Recipe) -> Recipe:
        branch_name = self.branch_name(recipe)
        template = utils.jinja.get_template("bump_pr.md")
        author = self.get_github_author(recipe)

        body = template.render({
            'r': recipe,
            'recipe_relurl': self.ghub.get_file_relurl(recipe.dir, branch_name),
            'author': author,
            'author_is_member': await self.ghub.is_member(author),
            'dependency_diff': self.render_deps_diff(recipe),
        })
        labels = ["autobump"]
        title = f"Update {recipe} to {recipe.version}"

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

        logger.info("Created PR %i updating %s to %s", pull['number'], recipe, recipe.version)
        return recipe


class MaxUpdates(Filter):
    """Terminate loop after **max_updates** Recipes have been updated."""
    def __init__(self, scanner: Scanner, max_updates: int = 0) -> None:
        super().__init__(scanner)
        self.max = max_updates
        self.count = 0
        logger.warning("Will exit after %s updated recipes", max_updates)

    async def apply(self, recipe: Recipe) -> Recipe:
        self.count += 1
        if self.max and self.count == self.max:
            logger.warning("Reached update limit %s", self.count)
            raise EndProcessing()
        return recipe
