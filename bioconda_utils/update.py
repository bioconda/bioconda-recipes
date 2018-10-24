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

- Subclasses of `Hoster` define how to handle each hoster. Hosters are
  selected by regex matching each source URL in a recipe. The
  `HTMLHoster` provides parsing for hosting sites listing new
  releases in HTML format (probably covers most). Adding a hoster is
  as simple as defining a regex to match the existing source URL, a
  formatting string creating the URL of the relases page and a regex
  to match links and extract their version.

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

- We need to use `regex` rather than `re` to allow recursive matching
  to manipulate capture groups in URL patterns as
  needed. (Technically, we could avoid this using a Snakemake wildcard
  type syntax to define the patterns - implementers welcome).

- We use `ruamel.yaml` to know where in a ``.yaml`` file a value is
  defined. Ideally, we would extend its round-trip type to handle the
  `# [exp]` line selectors and at least simple parts of Jinja2
  template expansion.

- Using `git` simply looks nicer than doing lot of `subprocess` calls
  ourselves. An `asyncio` version would be nice though.

"""

import abc
import asyncio
import inspect
import logging
import os

from collections import defaultdict, Counter
from concurrent.futures import ThreadPoolExecutor
from copy import copy
from hashlib import sha256
from html.parser import HTMLParser
from urllib.parse import urljoin
from typing import Any, Dict, List, Mapping, Match, Optional, Pattern, \
    Sequence, Set, Tuple

import aiohttp
import aiofiles
import backoff
import regex as re
import git

from conda.models.version import VersionOrder
from ruamel.yaml import YAML
from ruamel.yaml.constructor import DuplicateKeyError
from gidgethub import aiohttp as gh_aiohttp
from pkg_resources import parse_version
from tqdm import tqdm

from . import utils

# pkg_resources.parse_version returns a Version or LegacyVersion object
# as defined in packaging.version. Since it's bundling it's own copy of
# packaging, the class it returns is not the same as the one we can import.
# So we cheat by having it create a LegacyVersion delibarately.
LegacyVersion = parse_version("").__class__  # pylint: disable=invalid-name

yaml = YAML(typ="rt")  # pylint: disable=invalid-name
logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


#: Matches named capture groups
#: This is so complicated because we need to parse matched, not-escaped parentheses to
#: determine where the clause ends.
#: Requires regex package for recursion.
RE_CAPGROUP = re.compile(r"\(\?P<(\w+)>(?>[^()]+|\\\(|\\\)|(\((?>[^()]+|\\\(|\\\)|(?2))*\)))*\)")


def dedup_named_capture_group(pattern):
    """Replaces repetitions of capture groups with matches to first instance"""
    seen: Set[str] = set()

    def replace(match):
        name: str = match.group(1)
        if name in seen:
            return f"(?P={name})"
        seen.add(name)
        return match.group(0)
    return re.sub(RE_CAPGROUP, replace, pattern)


def replace_named_capture_group(pattern, vals: Dict[str, str]):
    """Replaces capture groups with values from **vals**"""
    def replace(match):
        name = match.group(1)
        if name in vals:
            return vals[name]
        return match.group(0)
    return re.sub(RE_CAPGROUP, replace, pattern)


class Recipe():
    """Represents a recipe (meta.yaml) in editable form

    Using conda-build to render recipe is slow and a one-way process. We need
    to be able to load **and** save recipes, which is handled by the representation
    in this class.

    Recipes undergo two manipulation rounds before parsed as YAML:
     1. Selecting lines using ``# [expression]``
     2. Rendering as Jinja2 template

    (1) is currently unhandled, leading to recipes with repeated mapping keys
    (commonly two ``url`` keys). Those recipes are ignored for the time being.
    """
    JINJA_VARS = {
        "cran_mirror": "https://cloud.r-project.org"
    }

    def __init__(self, recipe_dir, recipe_folder):
        if not recipe_dir.startswith(recipe_folder):
            raise RuntimeError(f"{recipe_folder} is not prefix of {recipe_dir}")
        self.dir = recipe_dir
        self.basedir = recipe_folder
        self.reldir = recipe_dir[len(recipe_folder):].strip("/")
        self.path = os.path.join(self.dir, "meta.yaml")

        # Will be filled in by render
        self.version = ""
        self.name = ""
        self.config: Dict[str, Any] = {}
        self.meta: Dict[str, Any] = {}
        # Filled in by load
        self.meta_yaml: List[str] = []
        # Filled in by update filter
        self.version_data = None
        self.orig: Recipe = copy(self)

    def __str__(self) -> str:
        return self.reldir

    def load_from_string(self, data) -> bool:
        """Load and `render` recipe contents from disk"""
        self.meta_yaml = data.splitlines()
        if not self.meta_yaml:
            return False
        if not self.render():
            return False
        self.orig = copy(self)
        return True

    def dump(self):
        """Dump recipe content"""
        return "\n".join(self.meta_yaml) + "\n"

    def render(self) -> bool:
        """Convert recipe text into data structure

        - create jinja template from recipe content
        - render template
        - parse yaml
        """
        template = utils.jinja_silent_undef.from_string("\n".join(self.meta_yaml))
        try:
            self.meta = yaml.load(template.render(self.JINJA_VARS))
        except DuplicateKeyError:
            logger.error("Recipe %s: duplicate key", self)
            return False
        try:
            self.version = str(self.meta["package"]["version"])
            self.name = self.meta["package"]["name"]
        except KeyError as ex:
            raise RuntimeError(f"{self.dir} yaml missing {ex.args[0]}")
        self.config = self.meta.get("extra", {}).get("watch", {})
        return True

    def replace(self, before: str, after: str,
                within: Sequence[str] = ("package", "source")) -> bool:
        """Runs string replace on parts of recipe text.

        - Lines considered are those containing Jinja set statements
        (``{% set var="val" %}``) and those defining the top level
        Mapping entries given by **within** (default:``package`` and
        ``source``).

        - Cowardly refuses to modify lines with ``# [expression]``
        selectors.
        """
        # get lines starting with "{%"
        lines = set()
        for lineno, line in enumerate(self.meta_yaml):
            if line.strip().startswith("{%"):
                lines.add(lineno)

        # get lines covered by keys listed in ``within``
        start: Optional[int] = None
        for key in self.meta.keys():
            lineno = self.meta[key].lc.line
            if key in within:
                if start is None:
                    start = lineno
            else:
                if start is not None:
                    lines.update(range(start, lineno))
                    start = None
        if start is not None:
            lines.update(range(start, len(self.meta_yaml)))

        # replace within those lines, erroring on "# [asd]" selectors
        replacements = 0
        for lineno in sorted(lines):
            line = self.meta_yaml[lineno]
            if before not in line:
                continue
            if re.search(re.escape(before) + r".*#.*\[", line):
                logger.error("Recipe %s: cannot replace %s->%s "
                             "due to '# [flag]' selector in line %i",
                             self, before, after, line)
                return False
            self.meta_yaml[lineno] = line.replace(before, after)
            replacements += 1
        logger.debug("Replaced in %s: %s -> %s (%i times)", self, before, after, replacements)
        return True

    def reset_buildnumber(self) -> bool:
        """Resets the build number"""
        lineno: int = self.meta["build"].lc.key("number")[0]
        line = self.meta_yaml[lineno]
        line = re.sub("number: [0-9]+", "number: 0", line)
        self.meta_yaml[lineno] = line
        return True


class Filter(abc.ABC):
    """Function object type called by Scanner"""
    def __init__(self, scanner: "Scanner") -> None:
        self.scanner = scanner

    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> bool:
        """Process a recipe. Returns False if processing should stop"""

    def finalize(self) -> None:
        """Called at the end of a run"""


class Scanner():
    """Scans recipes and applies filters in asyncio loop

    Arguments:
      recipe_folder: location of recipe directories
      packages: glob pattern to select recipes
      config: config.yaml (unused)
    """
    class EndProcessing(BaseException):
        """For Filters to tell the scanner to stop"""

    def __init__(self, recipe_folder: str, packages: str, config: str) -> None:
        with open(config, "r") as config_file:
            self.config = yaml.load(config_file)
        #: folder containing recipes
        self.recipe_folder: str = recipe_folder
        #: list of recipe folders to scan
        self.recipes: List[str] = list(utils.get_recipes(self.recipe_folder, packages))
        try:  # get or create loop (threads don't have one)
            self.loop = asyncio.get_event_loop()
        except RuntimeError:
            self.loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.loop)
        #: executor for running local io
        self.executor: ThreadPoolExecutor = ThreadPoolExecutor()
        #: semaphore to limit io parallelism
        self.io_sem: asyncio.Semaphore = asyncio.Semaphore(1)
        #: counter to gather stats on various states
        self.stats: Counter = Counter()
        #: aiohttp session (only exists while running)
        self.session: aiohttp.ClientSession = None
        #: filters
        self.filters: List[Filter] = []

    def add(self, filt: Filter, *args, **kwargs) -> None:
        """Adds `Filter` to this `Scanner`"""
        self.filters.append(filt(self, *args, **kwargs))

    def run(self) -> bool:
        """Runs scanner

        This starts the asyncio loop and manages shutdown.
        """
        try:
            task = asyncio.ensure_future(self._async_run())
            self.loop.run_until_complete(task)
            logger.warning("Finished update")
        except (KeyboardInterrupt, self.EndProcessing) as exc:
            if isinstance(exc, KeyboardInterrupt):
                logger.error("Ctrl-C pressed - aborting...")
            if isinstance(exc, self.EndProcessing):
                logger.error("Terminating...")
            task.cancel()
            try:
                self.loop.run_until_complete(task)
            except asyncio.CancelledError:
                pass
        for key, value in self.stats.most_common():
            logger.info("%s: %s", key, value)
        for filt in self.filters:
            filt.finalize()
        return task.result()

    async def _async_run(self) -> bool:
        """Runner within async loop"""
        async with aiohttp.ClientSession() as session:
            self.session = session
            coros = [
                asyncio.ensure_future(
                    self.process(recipe_dir)
                )
                for recipe_dir in self.recipes
            ]
            try:
                with tqdm(asyncio.as_completed(coros),
                          total=len(coros)) as tcoros:
                    return all([await coro for coro in tcoros])
            except asyncio.CancelledError:
                for coro in coros:
                    coro.cancel()
                await asyncio.wait(coros)
                return False

    async def process(self, recipe_dir: str) -> bool:
        """Applies the filters to a recipe"""
        try:
            recipe = Recipe(recipe_dir, self.recipe_folder)
            for filt in self.filters:
                if not await filt.apply(recipe):
                    return False
        except asyncio.CancelledError:
            return False
        except Exception:  # pylint: disable=broad-except
            logger.exception("While processing %s", recipe_dir)
            return False

    async def run_io(self, func, *args):
        """Run **func** in thread pool executor using **args**"""
        async with self.io_sem:
            return await self.loop.run_in_executor(self.executor, func, *args)

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_text_from_url(self, url: str) -> str:
        """Fetch content at **url** and return as text

        - On non-permanent errors (429, 502, 503, 504), the GET is retried 10 times with
        increasing wait times according to fibonacci series.
        - Permanent errors raise a ClientResponseError
        """
        async with self.session.get(url) as resp:
            resp.raise_for_status()
            return await resp.text()

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_checksum_from_url(self, url: str, desc: str) -> str:
        """Compute sha256 checksum of content at **url**

        Shows TQDM progress monitor with label **desc**.
        """
        checksum = sha256()
        async with self.session.get(url) as resp:
            resp.raise_for_status()
            size = int(resp.headers.get("Content-Length", 0))
            with tqdm(total=size, unit='B', unit_scale=True, unit_divisor=1024,
                      desc=desc, miniters=1, leave=False, disable=None) as progress:
                while True:
                    block = await resp.content.read(1024*1024)
                    if not block:
                        break
                    progress.update(len(block))
                    await self.loop.run_in_executor(self.executor, checksum.update, block)
        return checksum.hexdigest()

    def get_github(self):
        """Create gidget GithubAPI object from session"""
        return gh_aiohttp.GitHubAPI(self.session,
                                    "bioconda/autobump",
                                    oauth_token=os.environ["GITHUB_TOKEN"])


class ExcludeOtherChannel(Filter):
    """Filters recipes matching packages in other **channels**"""
    def __init__(self, scanner: "Scanner", channels: Sequence[str],
                 cache: str) -> None:
        super().__init__(scanner)
        from .linting import channel_dataframe
        logger.info("Loading package lists for %s", channels)
        cdf = channel_dataframe(channels=channels, cache=cache)
        cdf['versionorder'] = cdf['version'].apply(VersionOrder)
        self.other_latest = cdf.groupby('name')['versionorder'].agg(max)

    async def apply(self, recipe):
        if recipe.name in self.other_latest:
            self.scanner.stats["SKIPPED_OTHER_CHANNEL"] += 1
            logger.info("Skipping %s because it's in other channels", recipe)
            return False
        return True


class ExcludeSubrecipe(Filter):
    """Filters sub-recipes

    Unless **always** is True, subrecipes specifically enabled via
    ``extra: watch: enable: yes`` will not be filtered.
    """
    def __init__(self, scanner: "Scanner", always=False) -> None:
        super().__init__(scanner)
        self.always_exclude = always

    async def apply(self, recipe):
        is_subrecipe = recipe.reldir.count("/") > 0
        enabled = recipe.config.get("enable", False)
        skip = is_subrecipe and not (enabled and not self.always_exclude)
        if skip:
            logger.debug("Skipping subrecipe %s", recipe)
            self.scanner.stats["SKIPPED_SUBRECIPE"] += 1
        return not skip


class ExcludeBlacklisted(Filter):
    """Filters blacklisted recipes"""
    def __init__(self, scanner):
        super().__init__(scanner)
        self.blacklisted = utils.get_blacklist(
            scanner.config["blacklists"],
            scanner.recipe_folder)
        logger.warning("Excluding %i blacklisted recipes", len(self.blacklisted))

    async def apply(self, recipe):
        if recipe.name in self.blacklisted:
            logger.debug("Excluding %s", recipe.name)
            self.scanner.stats["BLACKLISTED"] += 1
            return False
        return True


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
    def __init__(self, scanner: "Scanner") -> None:
        super().__init__(scanner)
        #: failed urls - for later inspection
        self.failed_urls: List[str] = []

    def finalize(self):
        if self.failed_urls:
            with open("failed_urls.txt", "w") as out:
                out.write("\n".join(self.failed_urls))

    async def apply(self, recipe: Recipe) -> bool:
        logger.debug("Checking for updates to %s - %s", recipe, recipe.version)

        sources = recipe.meta.get("source")
        if not sources:
            logger.info("Recipe %s is a metapackage (no sources)", recipe)
            self.scanner.stats["METAPACKAGE"] += 1
            return False

        if isinstance(sources, Mapping):
            versions = await self.get_versions(recipe, sources, 1)
            if not versions:
                return False
            latest = self.select_version(recipe.version, versions.keys())
            recipe.version_data = versions[latest]
        else:
            self.scanner.stats["MULTISOURCE"] += 1
            logger.info("Recipe %s is multi-source", recipe)
            # FIXME: handle multisource
            #for n, source in enumerate(sources):
            #    self.update_source(sources, n)
            return False

        if latest == recipe.version:
            logger.debug("Recipe %s is up to date", recipe)
            self.scanner.stats["OK"] += 1
            return False

        logger.info("Recipe %s has a new version %s > %s", recipe, latest, recipe.version)
        self.scanner.stats["HAVE_UPDATE"] += 1

        if not recipe.replace(recipe.version, latest):
            self.scanner.stats["UPDATE_FAIL_VERSION"] += 1
            return False
        if not recipe.reset_buildnumber():
            self.scanner.stats["UPDATE_FAIL_BUILNO"] += 1
            return False
        if not recipe.render():
            self.scanner.stats["UPDATE_FAIL_RENDER"] += 1
            return False
        if recipe.version != latest:
            self.scanner.stats["UPDATE_FAIL_VERSION"] += 1
            return False
        return True

    async def get_versions(self, recipe: Recipe, source: Mapping[Any, Any],
                           source_idx: int):
        """Select hosters and retrieve versions for this source"""
        urls = source.get("url")
        if isinstance(urls, str):
            urls = [urls]
        if not urls:
            logger.info("Package %s has no url in source %i", recipe, source_idx+1)
            self.scanner.stats["ERROR_NO_URLS"] += 1
            return

        version_map: Dict[str, Dict[str, Any]] = defaultdict(dict)
        for url in urls:
            hoster = Hoster.select_hoster(url)
            if not hoster:
                self.scanner.stats["UNKNOWN_URL"] += 1
                logger.debug("Failed to parse url '%s'", url)
                self.failed_urls += [url]
                match = re.search(r"://([^/]+)/", url)
                if match:
                    self.scanner.stats[f"UNKNOWN_URL_{match.group(1)}"] += 1
                continue
            logger.debug("Scanning with %s", hoster.__class__.__name__)
            try:
                versions = await hoster.get_versions(self.scanner)
                for match in versions:
                    version_map[match["version"]][url] = match
            except aiohttp.ClientResponseError as exc:
                self.scanner.stats[f"HTTP_{exc.code}"] += 1
                logger.debug("HTTP %s when getting %s", exc, url)

        if not version_map:
            logger.debug("Failed to parse any url in %s", recipe)
            return

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

class UpdateChecksums(Filter):
    """Download upstream source files, recompute checksum and update Recipe"""

    async def apply(self, recipe: Recipe) -> bool:
        sources = recipe.meta["source"]
        logger.info("Updating checksum for %s %s", recipe, recipe.version)
        if isinstance(sources, Mapping):
            sources = [sources]
        res = all([await self.update_source(recipe, source, n)
                   for n, source in enumerate(sources)])
        if res:
            return recipe.render()
        self.scanner.stats["UPDATE_FAIL_CHECKSUM"] += 1
        return False

    async def update_source(self, recipe: Recipe, source: Mapping, source_idx: int) -> bool:
        """Updates one source

        Each source has its own checksum, but all urls in one source must have
        the same checksum (if the link is available).

        We don't fail if the link is not available as cargo-port will only update
        after the recipe was built and uploaded.
        """
        for checksum_type in ("sha256", "sha1", "md5"):
            checksum = source.get(checksum_type)
            if checksum:
                break
        else:
            logger.error("Recipe %s has no checksum", recipe)
            return False
        if checksum_type != "sha256":
            logger.error("Recipe %s has checksum type %s", recipe, checksum_type)
            if not recipe.replace(checksum_type, "sha256"):
                return False

        urls = source["url"]
        if isinstance(urls, str):
            urls = [urls]
        new_checksums = []
        for url_idx, url in enumerate(urls):
            try:
                res = await self.scanner.get_checksum_from_url(
                    url, f"{recipe} [{source_idx}.{url_idx}]")
            except aiohttp.client_exceptions.ClientResponseError:
                res = None
            new_checksums.append(res)
        count = len(set(c for c in new_checksums if c is not None))
        if count == 0:
            logger.error("Recipe %s: update failed - no valid urls in source %s",
                         recipe, source_idx)
            return False
        if count > 1:
            logger.error("Recipe %s: checksum mismatch on updated sources", recipe)
            for idx, (csum, url) in enumerate(zip(new_checksums, urls)):
                logger.error("Recipe %s: url %s - got %s for %s",
                             recipe, idx, csum, url)
            return False
        new_checksum = next(c for c in new_checksums if c is not None)
        if not recipe.replace(checksum, new_checksum):
            return False
        return True


class BranchNameMixin():
    @staticmethod
    def branch_name(recipe):
        return f"auto_update_{recipe.name.replace('-','_')}"


class CommitToBranch(Filter, BranchNameMixin):
    def __init__(self, scanner, ignore_dirty=False):
        super().__init__(scanner)
        self.repo = git.Repo(scanner.recipe_folder, search_parent_directories=True)
        if not ignore_dirty:
            if self.repo.is_dirty():
                raise RuntimeError("Repository is in dirty state. Bailing out")
            self.repo.heads["master"].checkout()
        self.from_commit = self.repo.remotes["upstream"].fetch("master")[0].commit
        self.git_sem = asyncio.Semaphore(1)  # there can be only one
        # update master if we are doing this
        # use finalize to restore state

    def make_branch(self, branch_name):
        logger.info("Creating branch %s", branch_name)
        if branch_name in self.repo.heads:
            self.repo.delete_head(branch_name, force=True)
        self.repo.create_head(branch_name, self.from_commit)
        branch = self.repo.heads[branch_name]
        branch.checkout()

    def commit_and_push_changes(self, recipe, branch_name):
        self.repo.index.add([recipe.path])
        self.repo.index.commit(f"Update {recipe.name} to {recipe.version}")
        logger.info("Pushing branch %s", branch_name)
        self.repo.remotes["origin"].push(branch_name, force=True)

    async def apply(self, recipe: Recipe) -> bool:
        branch_name = self.branch_name(recipe)
        async with self.git_sem:
            self.make_branch(branch_name)
            await recipe.write()
            self.commit_and_push_changes(recipe, branch_name)
        return True


class LoadRecipe(Filter):
    """Loads the Recipe from the filesystem"""
    async def apply(self, recipe: Recipe) -> bool:
        async with aiofiles.open(recipe.path, encoding="utf-8") as fd:
            return recipe.load_from_string(await fd.read())


class WriteRecipe(Filter):
    """Writes the Recipe to the filesystem"""
    async def apply(self, recipe: Recipe) -> bool:
        async with aiofiles.open(recipe.path, "w", encoding="utf-8") as fd:
            return await fd.write(recipe.dump())
        self.scanner.stats["UPDATED"] += 1
        return True


class CreatePullRequest(Filter, BranchNameMixin):
    def __init__(self, scanner):
        super().__init__(scanner)
        self.gh = None
        self.login: str = ""
        self.body_tpl = utils.jinja.get_template("bump_pr.md")

    async def apply(self, recipe):
        branch_name = self.branch_name(recipe)
        if not self.gh:
            self.gh = self.scanner.get_github()
            self.login = (await self.gh.getitem("/user"))["login"]
        pulls = "/repos/bioconda/bioconda-recipes/pulls{/number}{?head,base}"
        data = {
            "head": f"{self.login}:{branch_name}",
            "base": "master",
            "title": f"Update {recipe.name} to {recipe.version}",
            "body": self.body_tpl.render({'r':recipe}),
            "maintainer_can_modify": True,
            "labels": ["autobump"],
        }

        prs = await self.gh.getitem(pulls, data)
        if len(prs) == 0:
            pr = await self.gh.post(pulls, data=data)
            logger.warning("Created PR %i updating %s to %s", pr["number"], recipe.name, recipe.version)
            pr = await self.gh.patch(pr["issue_url"], data={"labels": ["autobump"]})
            logger.debug("Set label autobump on PR %i", pr["number"])
        else:
            for pr in prs:
                logger.warning("Found PR %i updating %s", pr["number"], recipe.name)
            # Fixme: if the existing PR was merged, create a new one
            #        if it was closed... well, we need to handle all this

        return True


class MaxUpdates(Filter):
    def __init__(self, scanner, max_updates: int=0) -> None:
        super().__init__(scanner)
        self.max = max_updates
        self.count = 0
        logger.warning("Will exit after %s updated recipes", max_updates)

    async def apply(self, recipe):
        self.count += 1
        if self.max and self.count == self.max:
            logger.warning("Reached update limit %s", self.count)
            raise self.scanner.EndProcessing()


class HosterMeta(abc.ABCMeta):
    """Meta-Class for Hosters

    By making Hosters classes of a metaclass, rather than instances of a class,
    we leave the option to add functions to a Hoster.
    """

    hoster_types: List["HosterMeta"] = []

    def __new__(mcs, name, bases, attrs, **opts):
        """Creates Hoster classes

        - expands references among ``{var}_pattern`` attributes
        - compiles ``{var}_pattern`` attributes to ``{var}_re``
        - registers complete classes
        """
        typ = super().__new__(mcs, name, bases, attrs, **opts)

        if inspect.isabstract(typ):
            return typ
        mcs.hoster_types.append(typ)

        patterns = {attr.replace("_pattern", ""): getattr(typ, attr)
                    for attr in dir(typ) if attr.endswith("_pattern")}

        for pat in patterns:
            # expand pattern references:
            pattern = ""
            new_pattern = patterns[pat]
            while pattern != new_pattern:
                pattern = new_pattern
                new_pattern = re.sub(r"(\{\d+,?\d*\})", r"{\1}", pattern)
                new_pattern = new_pattern.format_map(patterns)
            patterns[pat] = pattern
            # fix duplicate capture groups:
            pattern = dedup_named_capture_group(pattern)
            # save parsed and compiled pattern
            setattr(typ, pat + "_pattern", pattern)
            setattr(typ, pat + "_re", re.compile(pattern))
            logger.debug("%s Pattern %s = %s", typ.__name__, pat, pattern)

        return typ

    @classmethod
    def select_hoster(mcs, url: str) -> Optional["Hoster"]:
        """Select `Hoster` able to handle **url**

        Returns: `Hoster` or `None`
        """
        logger.debug("Matching url '%s'", url)
        for hoster_type in mcs.hoster_types:
            hoster = hoster_type.try_make_hoster(url)
            if hoster:
                return hoster
        return None


class Hoster(object, metaclass=HosterMeta):
    """Hoster Baseclass"""

    #: matches upstream version
    #: - begins with a number
    #: - then only numbers, characters or one of -, +, ., :, ~
    #: - at most 31 characters length (to avoid matching checksums)
    version_pattern: str = r"(?P<version>\d[\da-zA-Z\-+\.:\~]{0,30})"

    #: matches archive file extensions
    ext_pattern: str = r"(?P<ext>(?i)\.(?:tar\.(?:xz|bz2|gz)|zip))"

    @property
    @abc.abstractmethod
    def url_pattern(self) -> str:
        "matches upstream package url"

    @property
    @abc.abstractmethod
    def link_pattern(self) -> str:
        "matches links on relase page"

    @property
    @abc.abstractmethod
    def releases_format(self) -> str:
        "format template for release page URL"

    def __init__(self, url: str, match: Match[str]) -> None:
        logger.debug("%s matched %s with %s", self.__class__.__name__, url, match.groupdict())

    @classmethod
    def try_make_hoster(cls, url: str) -> Optional["Hoster"]:
        """Creates hoster if **url** is matched by its **url_pattern**"""
        match = cls.url_re.search(url)
        if match:
            return cls(url, match)
        return None

    @classmethod
    @abc.abstractmethod
    def get_versions(cls, scanner: Scanner) -> List[Mapping[str, str]]:
        ""


class HrefParser(HTMLParser):
    """Extract link targets from HTML"""
    def __init__(self, link_re: Pattern[str]):
        super().__init__()
        self.link_re = link_re
        self.matches: List[Mapping[str, str]] = []

    def handle_starttag(self, tag: str, attrs: List[Tuple[str, str]]) -> None:
        if tag == "a":
            for key, val in attrs:
                if key == "href":
                    self.handle_a_href(val)
                    break

    def handle_a_href(self, href: str) -> None:
        match = self.link_re.search(href)
        if match:
            data = match.groupdict()
            data["href"] = href
            self.matches.append(data)

    def error(self, message: str) -> None:
        logger.debug("Error parsing HTML: %s", message)


class HTMLHoster(Hoster):
    """Base for Hosters handling release listings in HTML format"""

    def __init__(self, url: str, match: Match[str]) -> None:
        self.orig_match = match
        self.releases_url = self.releases_format.format(**match.groupdict())
        super().__init__(url, match)

    async def get_versions(self, scanner):
        exclude = set(["version"])
        vals = {key: val
                for key, val in self.orig_match.groupdict().items()
                if key not in exclude}
        link_pattern = replace_named_capture_group(self.link_pattern, vals)
        parser = HrefParser(re.compile(link_pattern))
        parser.feed(await scanner.get_text_from_url(self.releases_url))
        for match in parser.matches:
            match["link"] = urljoin(self.releases_url, match["href"])
            match["releases_url"] = self.releases_url
        return parser.matches


class OrderedHTMLHoster(HTMLHoster):
    """HTMLHoster for which we can expected newest releases at top

    The point isn't performance, but avoiding hassle with old versions
    which may follow different versioning schemes.
    E.g. 0.09 -> 0.10 -> 0.2 -> 0.2.1
    """

    async def get_versions(self, scanner):
        matches = await super().get_versions(scanner)
        if not matches:
            return matches
        for num, match in enumerate(matches):
            if match["version"] == self.orig_match["version"]:
                break
        return matches[:num+1]


class GithubRelease(OrderedHTMLHoster):
    """Matches release artifacts uploaded to Github"""
    link_pattern = (r"/(?P<account>[\w\-]*)/(?P<project>[\w\-]*)/releases/download/"
                    r"v?{version}/(?P<fname>[^/]+{ext})")
    url_pattern = r"github.com{link}"
    releases_format = "https://github.com/{account}/{project}/releases"


class GithubTag(OrderedHTMLHoster):
    """Matches GitHub repository archives created automatically from tags"""
    link_pattern = r"/(?P<account>[\w\-]*)/(?P<project>[\w\-]*)/archive/v?{version}{ext}"
    url_pattern = r"github.com{link}"
    releases_format = "https://github.com/{account}/{project}/tags"


class Bioconductor(HTMLHoster):
    """Matches R packages hosted at Bioconductor"""
    link_pattern = r"/src/contrib/(?P<package>[^/]+)_{version}{ext}"
    url_pattern = r"bioconductor.org/packages/(?P<bioc>[\d\.]+)/bioc{link}"
    releases_format = "https://bioconductor.org/packages/{bioc}/bioc/html/{package}.html"


class DepotGalaxyProject(HTMLHoster):
    """Matches source backup urls created by cargo-port"""
    os_pattern = r"_(?P<os>src_all|linux_x86|darwin_x86)"
    link_pattern = r"(?P<package>[^/]+)_{version}{os}{ext}"
    url_pattern = r"depot.galaxyproject.org/software/(?P<package>[^/]+)/{link}"
    releases_format = "https://depot.galaxyproject.org/software/{package}/"


logger.info(f"Hosters loaded: %s", [h.__name__ for h in HosterMeta.hoster_types])
