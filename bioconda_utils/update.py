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
import pickle

from collections import defaultdict, Counter
from copy import copy
from hashlib import sha256
from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse
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
#: This is so complicated because we need to parse matched, not-escaped
#: parentheses to determine where the clause ends.
#: Requires regex package for recursion.
RE_CAPGROUP = re.compile(r"\(\?P<(\w+)>(?>[^()]+|\\\(|\\\)|(\((?>[^()]+|\\\(|\\\)|(?2))*\)))*\)")


def dedup_named_capture_group(pattern):
    """Replaces repetitions of capture groups with matches to first instance"""
    seen: Set[str] = set()

    def replace(match):
        "inner replace"
        name: str = match.group(1)
        if name in seen:
            return f"(?P={name})"
        seen.add(name)
        return match.group(0)
    return re.sub(RE_CAPGROUP, replace, pattern)


def replace_named_capture_group(pattern, vals: Dict[str, str]):
    """Replaces capture groups with values from **vals**"""
    def replace(match):
        "inner replace"
        name = match.group(1)
        if name in vals:
            return vals[name]
        return match.group(0)
    return re.sub(RE_CAPGROUP, replace, pattern)


class EndProcessing(BaseException):
    """Raised by `Filter` to tell `Scanner` to stop processing"""


class RecipeError(Exception):
    """Raised to indicate processing of Recipe failed"""
    __slots__ = ['recipe', 'args']
    template = "broken: %s"

    def __init__(self, recipe: "Recipe", *args) -> None:
        super().__init__()
        self.recipe = recipe
        self.args = args

    def log(self, logfunc):
        """Print message using provided logging func"""
        logfunc("Recipe %s " + self.template, self.recipe, *self.args)

    @property
    def name(self):
        return self.__class__.__name__


class Recipe():
    """Represents a recipe (meta.yaml) in editable form

    Using conda-build to render recipe is slow and a one-way
    process. We need to be able to load **and** save recipes, which is
    handled by the representation in this class.

    Recipes undergo two manipulation rounds before parsed as YAML:
     1. Selecting lines using ``# [expression]``
     2. Rendering as Jinja2 template

    (1) is currently unhandled, leading to recipes with repeated mapping keys
    (commonly two ``url`` keys). Those recipes are ignored for the time being.

    Arguments:
      recipe_folder: base recipes folder
      recipe_dir: path to specific recipe
    """

    #: Variables to pass to Jinja when rendering recipe
    JINJA_VARS = {
        "cran_mirror": "https://cloud.r-project.org"
    }

    #: Name of key under ``extra`` containing config
    EXTRA_CONFIG = "watch"

    def __init__(self, recipe_dir, recipe_folder):
        if not recipe_dir.startswith(recipe_folder):
            raise RuntimeError(f"'{recipe_dir}' not inside '{recipe_folder}'")

        #: path to folder containing recipes
        self.basedir = recipe_folder
        #: relative path to recipe dir from folder containing recipes
        self.reldir = recipe_dir[len(recipe_folder):].strip("/")

        # These are filled in by render()
        #: Version of package(s) built by recipe
        self.version = ""
        #: Name of toplevel package built by recipe
        #: Important: this may be different from the Recipe's "name" (`reldir`)
        #: and may not list all packages built by the recipe (``outputs:``).
        self.name = ""
        #: Parsed recipe YAML
        self.meta: Dict[str, Any] = {}

        # These will be filled in by load_from_string()
        #: Lines of the raw recipe file
        self.meta_yaml: List[str] = []
        #: Original recipe before modifications
        self.orig: Recipe = copy(self)

    @property
    def path(self):
        """Full path to `meta.yaml``"""
        return os.path.join(self.basedir, self.reldir, "meta.yaml")

    @property
    def config(self):
        """Per-recipe configuration parameters

        These are the values set in ``extra:`` under the key
        defined as `Recipe.EXTRA_CONFIG` (default is ``watch``).
        """
        return self.meta.get("extra", {}).get(self.EXTRA_CONFIG, {})

    def __str__(self) -> str:
        return self.reldir

    def load_from_string(self, data) -> None:
        """Load and `render` recipe contents from disk"""
        self.meta_yaml = data.splitlines()
        if not self.meta_yaml:
            raise RecipeError(self, "empty meta.yaml")
        self.render()
        self.orig = copy(self)

    def dump(self):
        """Dump recipe content"""
        return "\n".join(self.meta_yaml) + "\n"

    def render(self) -> None:
        """Convert recipe text into data structure

        - create jinja template from recipe content
        - render template
        - parse yaml
        """
        template = utils.jinja_silent_undef.from_string(
            "\n".join(self.meta_yaml)
        )
        try:
            self.meta = yaml.load(template.render(self.JINJA_VARS))
        except DuplicateKeyError:
            raise RecipeError(self, "duplicate key")
        try:
            self.version = str(self.meta["package"]["version"])
            self.name = self.meta["package"]["name"]
        except KeyError as exc:
            raise RecipeError(self, "missing %s", exc.args)

    def replace(self, before: str, after: str,
                within: Sequence[str] = ("package", "source")) -> int:
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
                raise RecipeError(self, "cannot replace %s->%s due to "
                                  "'# [flag]' selector in line %i",
                                  before, after, line)
            self.meta_yaml[lineno] = line.replace(before, after)
            replacements += 1
        logger.debug("Replaced in %s: %s -> %s (%i times)",
                     self, before, after, replacements)
        return replacements

    def reset_buildnumber(self):
        """Resets the build number"""
        try:
            lineno: int = self.meta["build"].lc.key("number")[0]
        except KeyError: # no build number?
            raise RecipeError(self, "missing build number")
        line = self.meta_yaml[lineno]
        line = re.sub("number: [0-9]+", "number: 0", line)
        self.meta_yaml[lineno] = line


class Filter(abc.ABC):
    """Function object type called by Scanner"""
    def __init__(self, scanner: "Scanner") -> None:
        self.scanner = scanner

    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> bool:
        """Process a recipe. Returns False if processing should stop"""

    async def async_init(self) -> None:
        """Called inside loop before processing"""

    def finalize(self) -> None:
        """Called at the end of a run"""


class Scanner():
    """Scans recipes and applies filters in asyncio loop

    Arguments:
      recipe_folder: location of recipe directories
      packages: glob pattern to select recipes
      config: config.yaml (unused)
    """
    def __init__(self, recipe_folder: str, packages: List[str], config: str, cache_fn: str) -> None:
        with open(config, "r") as config_file:
            #: config
            self.config = yaml.load(config_file)
            self.config['blacklists'] = [
                os.path.join(os.path.dirname(config), bl)
                for bl in self.config['blacklists']
            ]
        #: folder containing recipes
        self.recipe_folder: str = recipe_folder
        #: glob expressions
        self.packages: List[str] = packages
        try:  # get or create loop (threads don't have one)
            self.loop = asyncio.get_event_loop()
        except RuntimeError:
            self.loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.loop)
        #: semaphore to limit io parallelism
        self.io_sem: asyncio.Semaphore = asyncio.Semaphore(1)
        #: counter to gather stats on various states
        self.stats: Counter = Counter()
        #: aiohttp session (only exists while running)
        self.session: aiohttp.ClientSession = None
        #: filters
        self.filters: List[Filter] = []
        #: cache file name (for debugging)
        self.cache_fn: str = cache_fn
        #: cache
        self.cache: Optional[Dict[str, Dict[str, str]]] = None
        if cache_fn:
            if os.path.exists(cache_fn):
                with open(cache_fn, "rb") as stream:
                    self.cache = pickle.load(stream)
            else:
                self.cache = {}
            if "url_text" not in self.cache:
                self.cache["url_text"] = {}
            if "url_checksum" not in self.cache:
                self.cache["url_checksum"] = {}

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
        except (KeyboardInterrupt, EndProcessing) as exc:
            if isinstance(exc, KeyboardInterrupt):
                logger.error("Ctrl-C pressed - aborting...")
            if isinstance(exc, EndProcessing):
                logger.error("Terminating...")
            task.cancel()
            try:
                self.loop.run_until_complete(task)
            except asyncio.CancelledError:
                pass
        for key, value in self.stats.most_common():
            logger.info("%s: %s", key, value)
        logger.info("SUM: %i", sum(self.stats.values()))
        for filt in self.filters:
            filt.finalize()
        if self.cache_fn:
            with open(self.cache_fn, "wb") as stream:
                pickle.dump(self.cache, stream)
        return task.result()

    async def _async_run(self) -> bool:
        """Runner within async loop"""
        async with aiohttp.ClientSession() as session:
            self.session = session
            await asyncio.gather(*(filt.async_init() for filt in self.filters))
            coros = [
                asyncio.ensure_future(
                    self.process(recipe_dir)
                )
                for recipe_dir in utils.get_recipes(self.recipe_folder, self.packages)
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
        recipe = Recipe(recipe_dir, self.recipe_folder)
        try:
            for filt in self.filters:
                result = await filt.apply(recipe)
                if result == False:
                    return False
        except asyncio.CancelledError:
            return False
        except RecipeError as recipe_error:
            recipe_error.log(logger.info)
            self.stats[recipe_error.name] += 1
            return False
        except Exception:  # pylint: disable=broad-except
            logger.exception("While processing %s", recipe_dir)
            return False
        self.stats["Updated"] += 1
        return True

    async def run_io(self, func, *args):
        """Run **func** in thread pool executor using **args**"""
        async with self.io_sem:
            return await self.loop.run_in_executor(None, func, *args)

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_text_from_url(self, url: str) -> str:
        """Fetch content at **url** and return as text

        - On non-permanent errors (429, 502, 503, 504), the GET is retried 10 times with
        increasing wait times according to fibonacci series.
        - Permanent errors raise a ClientResponseError
        """
        if self.cache and url in self.cache["url_text"]:
            return self.cache["url_text"][url]

        async with self.session.get(url) as resp:
            resp.raise_for_status()
            res = await resp.text()

        if self.cache:
            self.cache["url_text"][url] = res

        return res

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_checksum_from_url(self, url: str, desc: str) -> str:
        """Compute sha256 checksum of content at **url**

        Shows TQDM progress monitor with label **desc**.
        """
        if self.cache and url in self.cache["url_checksum"]:
            return self.cache["url_checksum"][url]

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
                    await self.loop.run_in_executor(None, checksum.update, block)
        res = checksum.hexdigest()

        if self.cache:
            self.cache["url_checksum"][url] = res

        return res


class ExcludeOtherChannel(Filter):
    """Filters recipes matching packages in other **channels**"""

    class OtherChannel(RecipeError):
        template = "Recipe %s is in excluded channels%s"

    def __init__(self, scanner: "Scanner", channels: Sequence[str],
                 cache: str) -> None:
        super().__init__(scanner)
        from .linting import channel_dataframe
        logger.info("Loading package lists for %s", channels)
        cdf = channel_dataframe(channels=channels, cache=cache)
        cdf['versionorder'] = cdf['version'].apply(VersionOrder)
        self.other_latest = cdf.groupby('name')['versionorder'].agg(max)

    async def apply(self, recipe):
        # FIXME: handle recipes with multiple outputs
        if recipe.name in self.other_latest:
            raise self.OtherChannel(recipe)


class ExcludeSubrecipe(Filter):
    """Filters sub-recipes

    Unless **always** is True, subrecipes specifically enabled via
    ``extra: watch: enable: yes`` will not be filtered.
    """

    class IsSubRecipe(RecipeError):
        template = "is a subrecipe"

    def __init__(self, scanner: "Scanner", always=False) -> None:
        super().__init__(scanner)
        self.always_exclude = always

    async def apply(self, recipe):
        is_subrecipe = recipe.reldir.strip("/").count("/") > 0
        enabled = recipe.config.get("enable", False)
        if is_subrecipe and not (enabled and not self.always_exclude):
            raise self.IsSubRecipe(recipe)


class ExcludeBlacklisted(Filter):
    """Filters blacklisted recipes"""

    class Blacklisted(RecipeError):
        template = "is blacklisted"

    def __init__(self, scanner):
        super().__init__(scanner)
        self.blacklisted = utils.get_blacklist(
            scanner.config["blacklists"],
            scanner.recipe_folder)
        logger.warning("Excluding %i blacklisted recipes", len(self.blacklisted))

    async def apply(self, recipe):
        if recipe.reldir in self.blacklisted:
            raise self.Blacklisted(recipe)


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

    class Metapackage(RecipeError):
        template = "builds a meta package (recipe has no sources)"

    class Multisource(RecipeError):
        template = "has multiple sources"

    class UpToDate(RecipeError):
        template = "is up to date"

    class UpdateVersionFailure(RecipeError):
        template = "could not be updated from %s to %s"

    class NoUrlInSource(RecipeError):
        template = "has no URL in source %i"

    class NoRecognizedSourceUrl(RecipeError):
        template = "has no URL in source %i recognized by any Hoster class"

    class UrlNotVersioned(RecipeError):
        template = "has URL not modified by version change"

    def __init__(self, scanner: "Scanner", failed_file: Optional[str] = None) -> None:
        super().__init__(scanner)
        #: failed urls - for later inspection
        self.failed_urls: List[str] = []
        #: output file name for failed urls
        self.failed_file = failed_file

    def finalize(self):
        stats = Counter()
        for url in self.failed_urls:
            parsed = urlparse(url)
            stats[parsed.scheme] += 1
            stats[parsed.netloc] += 1
        logger.info("Unrecognized URL stats:")
        for key, value in stats.most_common():
            logger.info("%s: %i", key, value)

        if self.failed_urls and self.failed_file:
            with open(self.failed_file, "w") as out:
                out.write("\n".join(self.failed_urls))

    async def apply(self, recipe: Recipe):
        logger.debug("Checking for updates to %s - %s", recipe, recipe.version)

        sources = recipe.meta.get("source")
        if not sources:
            raise self.Metapackage(recipe)

        if isinstance(sources, Sequence):
            # FIXME: handle multisource
            raise self.Multisource(recipe)

        versions = await self.get_versions(recipe, sources, 1)
        latest = self.select_version(recipe.version, versions.keys())

        if latest == recipe.version:
            raise self.UpToDate(recipe)

        recipe.replace(recipe.version, latest)
        recipe.reset_buildnumber()
        recipe.render()

        if not recipe.version == latest:
            raise self.UpdateVersionFailure(recipe, recipe.orig.version, latest)

        if isinstance(recipe.meta["source"]["url"], str):
            if recipe.meta["source"]["url"] == recipe.orig.meta["source"]["url"]:
                raise self.UrlNotVersioned(recipe)
        else:
            for orig_url, url in zip(recipe.meta["source"]["url"],
                                     recipe.orig.meta["source"]["url"]):
                if orig_url == url:
                    raise self.UrlNotVersioned(recipe)

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
            hoster = Hoster.select_hoster(url)
            if not hoster:
                self.failed_urls += [url]
                continue
            logger.debug("Scanning with %s", hoster.__class__.__name__)
            try:
                versions = await hoster.get_versions(self.scanner)
                for match in versions:
                    version_map[match["version"]][url] = match
            except aiohttp.ClientResponseError as exc:
                #self.scanner.stats[f"HTTP_{exc.code}"] += 1
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
            if "-" in vers: # ignore versions with local (FIXME)
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


class UpdateChecksums(Filter):
    """Download upstream source files, recompute checksum and update Recipe"""

    class NoValidUrls(RecipeError):
        template = "has no valid urls in source %i"

    class SourceUrlMismatch(RecipeError):
        template = "has urls in source %i pointing to different files"

    async def apply(self, recipe: Recipe) -> bool:
        sources = recipe.meta["source"]
        logger.info("Updating checksum for %s %s", recipe, recipe.version)
        if isinstance(sources, Mapping):
            sources = [sources]
        for source_idx,  source in enumerate(sources):
            await self.update_source(recipe, source, source_idx)
        recipe.render()
        # FIXME: check that we have new checksums

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
        if not checksum_type:
            raise RuntimeError("?")
        if checksum_type != "sha256":
            logger.error("Recipe %s had checksum type %s", recipe, checksum_type)
            if not recipe.replace(checksum_type, "sha256"):
                raise RuntimeError("Failed to replace checksum type?")

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
            raise self.NoValidUrls(recipe, source_idx)
        if count > 1:
            for idx, (csum, url) in enumerate(zip(new_checksums, urls)):
                logger.error("Recipe %s: url %s - got %s for %s",
                             recipe, idx, csum, url)
            raise self.SourceUrlMismatch(recipe, source_idx)
        new_checksum = next(c for c in new_checksums if c is not None)
        if not recipe.replace(checksum, new_checksum):
            raise RuntimeError("Failed to replace checksum?")


class GitHandler():
    """Encapsulates code to interact with git repo

    Arguments:
      recipe_folder: Base folder containing recipes (needed to determine
                     location of git repo).
    """
    def __init__(self, recipe_folder):
        #: current repository
        self.repo = git.Repo(recipe_folder, search_parent_directories=True)
        if self.repo.is_dirty():
            raise RuntimeError("Repository is in dirty state. Bailing out")

        abs_recipe_folder = os.path.abspath(recipe_folder)
        abs_repo_root = os.path.abspath(self.repo.working_dir)
        self.rel_recipe_folder = abs_recipe_folder[len(abs_repo_root):].lstrip("/")

    def get_remote(self, desc):
        """Finds first remote containing **desc** in one of its URLs"""
        if desc in [r.name for r in self.repo.remotes]:
            return self.repo.remotes[desc]
        remotes = [r for r in self.repo.remotes
                   if any(filter(lambda x: desc in x, r.urls))]
        if not remotes:
            raise KeyError(f"No remote matching '{desc}' found")
        return remotes[0]

    async def check_branch(self, branch, path):
        rpath = os.path.join(self.rel_recipe_folder, path)
        proc = await asyncio.create_subprocess_exec(
            'git', 'log', '-1', '--oneline', '--decorate',
            f'master...{branch.name}', '--', rpath,
            stdout=asyncio.subprocess.PIPE)
        stdout, _ = await proc.communicate()
        return branch.name in stdout.decode('ascii')

    async def delete_branch(self, branch):
        proc = await asyncio.create_subprocess_exec(
            'git', 'branch', '-D', branch.name
        )
        return await proc.communicate()

    def get_branch(self, branch_name: str):
        """Finds branch named **branch_name**"""
        if branch_name in self.repo.heads:
            return self.repo.heads[branch_name]
        return None

    def read_from_branch(self, branch, file_name: str) -> str:
        """Reads contents of file **file_name** from git branch **branch**"""
        abs_file_name = os.path.abspath(file_name)
        abs_repo_root = os.path.abspath(self.repo.working_dir)
        if not abs_file_name.startswith(abs_repo_root):
            raise RuntimeError(
                f"File {abs_file_name} not inside {abs_repo_root}"
            )
        rel_file_name = abs_file_name[len(abs_repo_root):].lstrip("/")
        return (branch.commit.tree / rel_file_name).data_stream.read().decode("utf-8")

    def close(self):
        """Release resources allocated"""
        self.repo.close()


class GitFilter(Filter):
    """Base class for `Filter`s needing access to the git repo

    Arguments:
       scanner: Scanner we are called from
       git_handler: Instance of GitHandler for repo access
    """
    def __init__(self, scanner, git_handler):
        super().__init__(scanner)
        #: The `GitHandler` class for accessing repo
        self.git = git_handler
        self.repo = git_handler.repo

    @staticmethod
    def branch_name(recipe):
        """Render branch name from recipe"""
        return f"auto_update_{recipe.reldir.replace('-', '_').replace('/', '_')}"

    @abc.abstractmethod
    def apply(self, recipe):  # placate pylint by reiterating abstrace method
        pass


class LoadFromBranch(GitFilter):
    """Loads `Recipe` from git repo

    If the recipe has an update branch, the file from the update branch
    will be read. Otherwise, the file will be read from the master branch.

    FIXME: Handle merged branches
           The catch here is that we use Squash-Merge on Github, so the
           commit in the branch won't actually be merged (as in accessible from
           the commit tree from master).
           Best idea I've got is to go by modification time.
    """
    def __init__(self, scanner, git_handler):
        super().__init__(scanner, git_handler)
        self.sem = asyncio.Semaphore(1)

    async def async_init(self):
        # Fixme: does not work for subrecipes
        async def delete_if_bad(branch):
            recipe_dir = branch.name[len("auto_update_"):]
            if not await self.git.check_branch(branch, recipe_dir):
                logger.info("Deleting branch %s (master changed)", branch.name)
                await self.git.delete_branch(branch)
            else:
                logger.info("Found active update in branch %s", branch.name)

        await asyncio.gather(*[
            delete_if_bad(branch)
            for branch in self.git.repo.branches
            if branch.name.startswith("auto_update_")
        ])

    async def apply(self, recipe: Recipe) -> bool:
        branch_name = self.branch_name(recipe)
        logger.debug("Loading %s from branch %s", recipe, branch_name)
        branch = self.git.get_branch(branch_name)
        if not branch:
            branch = self.git.get_branch("master")
        async with self.sem:
            return recipe.load_from_string(
                await self.scanner.run_io(
                    self.git.read_from_branch, branch, recipe.path
                )
            )


class CommitToBranch(GitFilter):
    """Writes `Recipe` to git repo

    Arguments:
      upstream: Upstream remote (for pull)
      origin:   Origin remote (for push)
    """

    class NoChanges(RecipeError):
        template = "had no changes"

    def __init__(self, scanner, git_handler, upstream='bioconda/bioconda-recipe'):
        super().__init__(scanner, git_handler)
        #: Make sure only one "thread" is meddling with repo
        self.git_sem = asyncio.Semaphore(1)
        #: Branch to restore after running
        self.prev_active_branch = self.repo.active_branch
        #: Remote upstream (for pulling)
        self.upstream = self.git.get_remote(upstream)
        logger.warning("Using remote %s: %s", self.upstream.name,
                       ",".join(self.upstream.urls))

        logger.warning("Checking out master")
        self.repo.heads["master"].checkout()
        logger.info("Pulling from %s: %s", self.upstream.name, list(self.upstream.urls))
        self.upstream.pull("master")

        #: commit from which branches should derive
        self.from_commit = self.upstream.fetch('master')[0].commit

    def finalize(self):
        """Restore previously checked out branch"""
        logger.warning("Switching back to %s", self.prev_active_branch.name)
        self.prev_active_branch.checkout()

    def prepare_branch(self, branch_name):
        if branch_name not in self.repo.heads:
            logger.info("Creating new branch %sq", branch_name)
            self.repo.create_head(branch_name, self.from_commit)
        logger.info("Checking out branch %s", branch_name)
        branch = self.repo.heads[branch_name]
        branch.checkout()
        self.upstream.pull("master")

    def commit_and_push_changes(self, recipe, branch_name):
        self.repo.index.add([recipe.path])
        if not self.repo.index.diff("HEAD"):
            raise self.NoChanges(recipe)
        self.repo.index.commit(f"Update {recipe} to {recipe.version}")
        logger.info("Pushing branch %s", branch_name)
        self.repo.remotes["origin"].push(branch_name)

    async def apply(self, recipe: Recipe):
        branch_name = self.branch_name(recipe)
        async with self.git_sem:
            self.prepare_branch(branch_name)
            async with aiofiles.open(recipe.path, "w", encoding="utf-8") as fd:
                await fd.write(recipe.dump())
            self.commit_and_push_changes(recipe, branch_name)
            asyncio.sleep(1)  # let push settle before going on


class LoadRecipe(Filter):
    """Loads the Recipe from the filesystem"""
    def __init__(self, scanner):
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(10)

    async def apply(self, recipe: Recipe):
        async with self.sem, aiofiles.open(recipe.path, encoding="utf-8") as fd:
            recipe.load_from_string(await fd.read())


class WriteRecipe(Filter):
    """Writes the Recipe to the filesystem"""
    def __init__(self, scanner):
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(10)

    async def apply(self, recipe: Recipe):
        async with self.sem, aiofiles.open(recipe.path, "w", encoding="utf-8") as fd:
            await fd.write(recipe.dump())


class CreatePullRequest(GitFilter):
    PULLS = "/repos/{user}/{repo}/pulls{/number}{?head,base}"
    ISSUES = "/repos/{user}/{repo}/issues{/number}"

    class HasOpenPR(RecipeError):
        template = "has open PR(s) %s"

    def __init__(self, scanner, git_handler, token: str,
                 to_user: str = "bioconda",
                 to_repo: str = "bioconda-recipes") -> None:
        super().__init__(scanner, git_handler)
        self.token = token
        self.var_default = {'user': to_user,
                            'repo': to_repo}
        self.gh: Optional[gh_aiohttp.GitHubAPI] = None
        self.user: Dict[Any, Any] = None
        self.from_user = ""

    async def async_init(self):
        """Create gidget GithubAPI object from session"""
        # GitHub asks for user-agent to be set to something they can contact
        # if need be.
        user_agent = "bioconda/bioconda-utils"
        self.gh = gh_aiohttp.GitHubAPI(self.scanner.session, user_agent,
                                       oauth_token=self.token)
        asyncio.sleep(1)  # let API settle
        self.user = await self.gh.getitem("/user")
        self.from_user = self.user["login"]

    async def is_member(self, username):
        res = await self.gh.getitem("/orgs/:org/members/:username")


    async def get_prs(self,
                      from_branch: Optional[str] = None,
                      from_user: Optional[str] = None,
                      to_branch: Optional[str] = None,
                      number: Optional[int] = None) -> List[Dict[Any, Any]]:
        """Retrieve list of PRs

        Arguments:
          from_branch: Name of branch from which PR asks to pull
          from_user: Name of user/org in from which to pull
                     (default: from auth)
          to_branch: Name of branch into which to pull (default: master)
          number: PR number
        """
        var_data = copy(self.var_default)
        if not from_user:
            from_user = self.from_user
        if from_branch:
            if from_user:
                var_data['head'] = f"{from_user}:{from_branch}"
            else:
                var_data['head'] = from_branch
        if to_branch:
            var_data['base'] = to_branch
        if number:
            var_data['number'] = number

        return await self.gh.getitem(self.PULLS, var_data)

    async def create_pr(self, title: str,
                        recipe: Optional[Recipe] = None,
                        from_branch: Optional[str] = None,
                        from_user: Optional[str] = None,
                        to_branch: Optional[str] = "master",
                        body: Optional[str] = None,
                        body_template: Optional[str] = None,
                        maintainer_can_modify: bool = True) -> Dict[Any, Any]:
        """Create new PR

        Arguments:
          title: Title of new PR
          recipe: Recipe for which to create PR (fed into template)
          from_branch: Name of branch from which PR asks to pull
          from_user: Name of user/org in from which to pull
          to_branch: Name of branch into which to pull (default: master)
          body: Body text of PR
          body_template: Jinja2 template name for rendering body
          maintainer_can_modify: Whether to allow maintainer to modify from_branch
        """
        var_data = copy(self.var_default)
        if not from_user:
            from_user = self.from_user
        data = {'title': title,
                'body': '',
                'maintainer_can_modify': maintainer_can_modify}
        if body:
            data['body'] += body
        if body_template:
            template = utils.jinja.get_template(body_template)
            data['body'] += template.render({'r': recipe})
        if from_branch:
            if from_user:
                data['head'] = f"{from_user}:{from_branch}"
            else:
                data['head'] = from_branch
        if to_branch:
            data['base'] = to_branch

        logger.debug("PR data %s", data)
        return await self.gh.post(self.PULLS, var_data, data=data)

    async def modify_issue(self, number: int,
                           labels: Optional[List[str]]) -> Dict[Any, Any]:
        var_data = copy(self.var_default)
        var_data["number"] = str(number)
        data = {'labels': labels}
        return await self.gh.patch(self.ISSUES, var_data, data=data)

    async def apply(self, recipe):
        branch_name = self.branch_name(recipe)

        prs = await self.get_prs(from_branch=branch_name)
        if prs:
            for pr in prs:
                #head = pr["head"]["repo"]["full_name"]
                logger.warning("Found PR %i updating %s: %s", pr["number"],
                               recipe, pr["title"])
            raise self.HasOpenPR(recipe, ", ".join(pr["number"] for pr in prs))

        pr = await self.create_pr(title=f"Update {recipe} to {recipe.version}",
                                  from_branch=branch_name,
                                  body_template="bump_pr.md",
                                  recipe=recipe)
        pr_number = pr["number"]
        if pr_number:
            await self.modify_issue(number=pr_number, labels=["autobump"])

        logger.info("Created PR %i updating %s to %s", pr_number, recipe, recipe.version)


class MaxUpdates(Filter):
    """Terminate loop after **max_updates** Recipes have been updated."""
    def __init__(self, scanner, max_updates: int = 0) -> None:
        super().__init__(scanner)
        self.max = max_updates
        self.count = 0
        logger.warning("Will exit after %s updated recipes", max_updates)

    async def apply(self, recipe):
        self.count += 1
        if self.max and self.count == self.max:
            logger.warning("Reached update limit %s", self.count)
            raise EndProcessing()


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


class Hoster(metaclass=HosterMeta):
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

    FIXME: If the current version is not in the list, that's likely
           a pathologic case. Should be handled somewhere.
    """

    async def get_versions(self, scanner):
        matches = await super().get_versions(scanner)
        if not matches:
            return matches
        for num, match in enumerate(matches):
            if match["version"] == self.orig_match["version"]:
                break
        else:  # version not in list
            return matches
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
