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
import pickle
import random
import re

from collections import defaultdict, Counter
from concurrent.futures import ProcessPoolExecutor
from copy import copy
from hashlib import sha256
from urllib.parse import urlparse
from typing import Any, Dict, List, Mapping, Optional, Sequence

import aiohttp
import aiofiles
import backoff

import conda_build.variants
import conda_build.config
from conda.exports import MatchSpec, VersionOrder
import conda.exceptions

from ruamel.yaml import YAML
from ruamel.yaml.constructor import DuplicateKeyError
from pkg_resources import parse_version
from tqdm import tqdm

from . import utils
from .githubhandler import AiohttpGitHubHandler, GitHubHandler

# pkg_resources.parse_version returns a Version or LegacyVersion object
# as defined in packaging.version. Since it's bundling it's own copy of
# packaging, the class it returns is not the same as the one we can import.
# So we cheat by having it create a LegacyVersion delibarately.
LegacyVersion = parse_version("").__class__  # pylint: disable=invalid-name

yaml = YAML(typ="rt")  # pylint: disable=invalid-name
logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class EndProcessing(BaseException):
    """Raised by `Filter` to tell `Scanner` to stop processing"""


class RecipeError(Exception):
    """Raised to indicate processing of Recipe failed"""
    __slots__ = ['recipe', 'args']
    template = "broken: %s"
    level = logging.INFO

    def __init__(self, recipe: "Recipe", *args) -> None:
        super().__init__(recipe, *args)
        self.recipe = recipe
        self.args = args

    def log(self, uselogger=logger, level=None):
        """Print message using provided logging func"""
        if not level:
            level = self.level
        uselogger.log(level, "Recipe %s " + self.template, self.recipe, *self.args)

    @property
    def name(self):
        """Class name of RecipeError"""
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

    class DuplicateKey(RecipeError):
        template = "has duplicate key"

    class MissingKey(RecipeError):
        template = "has missing key"

    class EmptyRecipe(RecipeError):
        template = "is empty"

    class MissingBuild(RecipeError):
        template = "is missing build section"

    class HasSelector(RecipeError):
        template = "has selector in line %i (replace failed)"

    #: Variables to pass to Jinja when rendering recipe
    JINJA_VARS = {
        "cran_mirror": "https://cloud.r-project.org",
        "compiler": lambda x: f"compiler_{x}",
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

        # Filled in by render()
        #: Parsed recipe YAML
        self.meta: Dict[str, Any] = {}

        # These will be filled in by load_from_string()
        #: Lines of the raw recipe file
        self.meta_yaml: List[str] = []
        # Filled in by update filter
        self.version_data = None
        #: Original recipe before modifications (updated by load_from_string)
        self.orig: Recipe = copy(self)
        #: Whether the recipe was loaded from a branch (update in progress)
        self.on_branch: bool = False

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

    def load_from_string(self, data) -> "Recipe":
        """Load and `render` recipe contents from disk"""
        self.meta_yaml = data.splitlines()
        if not self.meta_yaml:
            raise self.EmptyRecipe(self)
        self.render()
        return self

    def set_original(self) -> None:
        """Store the current state of the recipe as "original" version"""
        self.orig = copy(self)

    def dump(self):
        """Dump recipe content"""
        return "\n".join(self.meta_yaml) + "\n"

    def render(self) -> None:
        """Convert recipe text into data structure

        - create jinja template from recipe content
        - render template
        - parse yaml
        - normalize
        """
        template = utils.jinja_silent_undef.from_string(
            "\n".join(self.meta_yaml)
        )
        try:
            self.meta = yaml.load(template.render(self.JINJA_VARS))
        except DuplicateKeyError:
            raise self.DuplicateKey(self)

        if ("package" not in self.meta
            or "version" not in self.meta["package"]
            or "name" not in self.meta["package"]):
            raise self.MissingKey(self)

        # make recipe-maintainers a list if it is a string
        maintainers = self.meta.mlget(["extra", "recipe-maintainers"])
        if maintainers and isinstance(maintainers, str):
            self.meta["extra"]["recipe-maintainers"] = [maintainers]

    @property
    def name(self) -> str:
        """The name of the toplevel package built by this recipe"""
        return self.meta["package"]["name"]

    @property
    def version(self) -> str:
        """The version of the package build by this recipe"""
        return str(self.meta["package"]["version"])

    @property
    def package_names(self) -> List[str]:
        """List of the packages built by this recipe (including outputs)"""
        packages = [self.name]
        if "outputs" in self.meta:
            packages.extend(output['name'] for output in self.meta['outputs'])
        return packages

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
            lineno = self.meta.lc.key(key)[0]
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
                raise self.HasSelector(self, lineno)
            self.meta_yaml[lineno] = line.replace(before, after)
            replacements += 1
        logger.debug("Replaced in %s: %s -> %s (%i times)",
                     self, before, after, replacements)
        return replacements

    def reset_buildnumber(self):
        """Resets the build number

        If the build number is missing, it is added after build.
        """
        try:
            lineno: int = self.meta["build"].lc.key("number")[0]
        except KeyError:  # no build number?
            if "build" in self.meta and self.meta["build"] is not None:
                build = self.meta["build"]
                first_in_build = next(iter(build))
                lineno, colno = build.lc.key(first_in_build)
                self.meta_yaml.insert(lineno, " "*colno + "number: 0")
            else:
                raise self.MissingBuild(self)

        line = self.meta_yaml[lineno]
        line = re.sub("number: [0-9]+", "number: 0", line)
        self.meta_yaml[lineno] = line


class Filter(abc.ABC):
    """Function object type called by Scanner"""
    def __init__(self, scanner: "Scanner") -> None:
        self.scanner = scanner

    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> Recipe:
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
    def __init__(self, recipe_folder: str, packages: List[str],
                 config: str, cache_fn: str, max_inflight: int = 100) -> None:
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
        self.proc_pool_executor = ProcessPoolExecutor(3)
        self.limit_inflight = asyncio.Semaphore(max_inflight)

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
            recipes = list(utils.get_recipes(self.recipe_folder, self.packages))
            random.shuffle(recipes)
            coros = [
                asyncio.ensure_future(
                    self.process(recipe_dir)
                )
                for recipe_dir in recipes
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
        async with self.limit_inflight:
            try:
                for filt in self.filters:
                    recipe = await filt.apply(recipe)
            except asyncio.CancelledError:
                return False
            except RecipeError as recipe_error:
                recipe_error.log(logger)
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

    async def run_sp(self, func, *args):
        """Run **func** in process pool executor using **args**"""
        return await self.loop.run_in_executor(self.proc_pool_executor, func, *args)

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
        template = "is in excluded channels"
        level = logging.DEBUG

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
        return recipe


class ExcludeSubrecipe(Filter):
    """Filters sub-recipes

    Unless **always** is True, subrecipes specifically enabled via
    ``extra: watch: enable: yes`` will not be filtered.
    """

    class IsSubRecipe(RecipeError):
        template = "is a subrecipe"
        level = logging.DEBUG

    def __init__(self, scanner: "Scanner", always=False) -> None:
        super().__init__(scanner)
        self.always_exclude = always

    async def apply(self, recipe):
        is_subrecipe = recipe.reldir.strip("/").count("/") > 0
        enabled = recipe.config.get("enable", False)
        if is_subrecipe and not (enabled and not self.always_exclude):
            raise self.IsSubRecipe(recipe)
        return recipe


class ExcludeBlacklisted(Filter):
    """Filters blacklisted recipes"""

    class Blacklisted(RecipeError):
        template = "is blacklisted"
        level = logging.DEBUG

    def __init__(self, scanner):
        super().__init__(scanner)
        self.blacklisted = utils.get_blacklist(
            scanner.config["blacklists"],
            scanner.recipe_folder)
        logger.warning("Excluding %i blacklisted recipes", len(self.blacklisted))

    async def apply(self, recipe):
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

    class Metapackage(RecipeError):
        template = "builds a meta package (recipe has no sources)"

    class Multisource(RecipeError):
        template = "has multiple sources"

    class UpToDate(RecipeError):
        template = "is up to date"
        level = logging.DEBUG

    class UpdateVersionFailure(RecipeError):
        template = "could not be updated from %s to %s"

    class NoUrlInSource(RecipeError):
        template = "has no URL in source %i"

    class NoRecognizedSourceUrl(RecipeError):
        template = "has no URL in source %i recognized by any Hoster class"
        level = logging.DEBUG

    class UrlNotVersioned(RecipeError):
        template = "has URL not modified by version change"

    def __init__(self, scanner: "Scanner", hoster_factory,
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

        sources = recipe.meta.get("source")
        if not sources:
            raise self.Metapackage(recipe)

        if isinstance(sources, Sequence):
            # FIXME: handle multisource
            raise self.Multisource(recipe)

        versions = await self.get_versions(recipe, sources, 0)
        conflicts = self.check_version_pin_conflict(recipe, versions)
        latest = self.select_version(recipe.version, versions.keys())
        recipe.version_data = versions[latest]

        if latest == recipe.version and not recipe.on_branch:
            raise self.UpToDate(recipe)

        for fn in versions[latest]:
            recipe.replace(fn, versions[latest][fn]['link'])
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
        return recipe

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
            hoster = self.hoster_factory(url)
            if not hoster:
                self.unparsed_urls += [url]
                continue
            logger.debug("Scanning with %s", hoster.__class__.__name__)
            try:
                versions = await hoster.get_versions(self.scanner)
                for match in versions:
                    version_map[match["version"]][url] = match
            except aiohttp.ClientResponseError as exc:
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
                                   versions: List[Dict[str, Any]]) -> List[str]:
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
                    ms = MatchSpec(version=spec.replace(" ",""))
                except conda.exceptions.InvalidVersionSpecError:
                    logger.error("Recipe %s: invalid upstream spec %s %s",
                                 recipe, pkg, repr(spec))
                    continue
                if norm_pkg in variants[0]:
                    for variant in variants:
                        if not ms.match({'name': '', 'build': '', 'build_number': 0,
                                         'version': variant[norm_pkg]}):
                            logger.error("Recipe %s: %s %s conflicts pins",
                                         recipe, pkg, spec)

        for version, files in versions.items():
            for fn, data in files.items():
                depends = data.get('depends')
                if depends:
                    check_pins(depends.items())


class UpdateChecksums(Filter):
    """Download upstream source files, recompute checksum and update Recipe"""

    class NoValidUrls(RecipeError):
        template = "has no valid urls in source %i"

    class SourceUrlMismatch(RecipeError):
        template = "has urls in source %i pointing to different files"


    def __init__(self, scanner: "Scanner",
                 failed_file: Optional[str] = None) -> None:
        super().__init__(scanner)
        #: failed urls - for later inspection
        self.failed_urls: List[str] = []
        #: unparsed urls - for later inspection
        self.failed_file = failed_file

    def finalize(self):
        if self.failed_urls:
            logger.warning("Encountered %i download failures while computing checksums",
                           len(self.failed_urls))
        if self.failed_urls and self.failed_file:
            with open(self.failed_file, "w") as out:
                out.write("\n".join(self.failed_urls))

    async def apply(self, recipe):
        sources = recipe.meta["source"]
        logger.info("Updating checksum for %s %s", recipe, recipe.version)
        if isinstance(sources, Mapping):
            sources = [sources]
        for source_idx,  source in enumerate(sources):
            await self.update_source(recipe, source, source_idx)
        recipe.render()
        # FIXME: check that we have new checksums
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

        urls = source["url"]
        if isinstance(urls, str):
            urls = [urls]
        new_checksums = []
        for url_idx, url in enumerate(urls):
            try:
                res = await self.scanner.get_checksum_from_url(
                    url, f"{recipe} [{source_idx}.{url_idx}]")
            except aiohttp.client_exceptions.ClientResponseError as exc:
                logger.info("Recipe %s: HTTP %s while downloading url %i",
                            recipe, exc.code, url_idx)
                self.failed_urls += ["\t".join((str(exc.code), url))]
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


class GitFilter(Filter):
    """Base class for `Filter`s needing access to the git repo

    Arguments:
       scanner: Scanner we are called from
       git_handler: Instance of GitHandler for repo access
    """

    branch_prefix = "auto_update_"

    def __init__(self, scanner, git_handler):
        super().__init__(scanner)
        #: The `GitHandler` class for accessing repo
        self.git = git_handler

    @classmethod
    def branch_name(cls, recipe):
        """Render branch name from recipe"""
        return f"{cls.branch_prefix}{recipe.reldir.replace('-', '_').replace('/', '_')}"

    @abc.abstractmethod
    def apply(self, recipe):  # placate pylint by reiterating abstrace method
        pass


class LoadRecipe(Filter):
    """Loads the Recipe from the filesystem"""
    def __init__(self, scanner):
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(10)

    async def apply(self, recipe):
        async with self.sem, aiofiles.open(recipe.path, encoding="utf-8") as fd:
            recipe_text = await fd.read()
        recipe = await self.scanner.run_sp(recipe.load_from_string, recipe_text)
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

    async def apply(self, recipe):
        branch_name = self.branch_name(recipe)
        remote_branch = self.git.get_remote_branch(branch_name)
        local_branch = self.git.get_local_branch(branch_name)

        if local_branch:
            logger.debug("Recipe %s: removing local branch %s", recipe, branch_name)
            self.git.delete_local_branch(local_branch)

        logger.debug("Recipe %s: loading from master", recipe)
        recipe_text = await self.scanner.run_io(self.git.read_from_branch,
                                                self.git.master, recipe.path)
        recipe = await self.scanner.run_sp(recipe.load_from_string, recipe_text)
        recipe.set_original()

        if remote_branch:
            if await self.git.branch_is_current(remote_branch, recipe.reldir):
                logger.info("Recipe %s: updating from remote %s", recipe, branch_name)
                recipe_text = await self.scanner.run_io(self.git.read_from_branch,
                                                        remote_branch, recipe.path)
                recipe = await self.scanner.run_sp(recipe.load_from_string, recipe_text)
                await self.scanner.run_io(self.git.create_local_branch, branch_name)
                recipe.on_branch = True
            else:
                # FIXME: this silently closes existing PR
                logger.info("Recipe %s: deleting outdated remote %s", recipe, branch_name)
                await self.scanner.run_io(self.git.delete_remote_branch, branch_name)
        return recipe


class WriteRecipe(Filter):
    """Writes the Recipe to the filesystem"""
    def __init__(self, scanner):
        super().__init__(scanner)
        self.sem = asyncio.Semaphore(10)

    async def apply(self, recipe):
        async with self.sem, aiofiles.open(recipe.path, "w", encoding="utf-8") as fd:
            await fd.write(recipe.dump())
        return recipe


class GitWriteRecipe(GitFilter):
    """Writes `Recipe` to git repo"""

    class NoChanges(RecipeError):
        template = "had no changes"

    async def apply(self, recipe):
        branch_name = self.branch_name(recipe)
        remote_branch = self.git.get_remote_branch(branch_name)
        changed = False
        async with self.git.lock_working_dir:
            self.git.prepare_branch(branch_name)
            async with aiofiles.open(recipe.path, "w", encoding="utf-8") as fd:
                await fd.write(recipe.dump())
            changed = self.git.commit_and_push_changes(recipe, branch_name)
        if changed:
            # CircleCI appears to have problems picking up on our PRs. Let's wait
            # a while before we create the PR, so the pushed branch has time to settle.
            await asyncio.sleep(10)  # let push settle before going on
        elif not recipe.on_branch:
            raise self.NoChanges(recipe)
        return recipe


class CreatePullRequest(GitFilter):
    """Creates or Updates PR on GitHub"""

    class UpdateInProgress(RecipeError):
        template = "has update in progress"

    class UpdateRejected(RecipeError):
        template = "had latest updated rejected manually"

    class FailedToCreatePR(RecipeError):
        template = "had failure in PR create"

    def __init__(self, scanner, git_handler, token: str,
                 dry_run: bool = False,
                 to_user: str = "bioconda",
                 to_repo: str = "bioconda-recipes") -> None:
        super().__init__(scanner, git_handler)
        self.gh: GitHubHandler = AiohttpGitHubHandler(
            token, dry_run, to_user, to_repo)

    async def async_init(self):
        """Create gidget GithubAPI object from session"""
        await self.gh.login(self.scanner.session)
        await asyncio.sleep(1)  # let API settle

    async def apply(self, recipe):
        branch_name = self.branch_name(recipe)
        template = utils.jinja.get_template("bump_pr.md")
        body = template.render({'r': recipe})
        labels = ["autobump"]
        title = f"Update {recipe} to {recipe.version}"

        # check if we already have an open PR (=> update in progress)
        prs = await self.gh.get_prs(from_branch=branch_name)
        if prs:
            if len(prs) > 1:
                logger.error("Multiple PRs updating %s: %s",
                             recipe,
                             ", ".join(pr['number'] for pr in prs))
            for pr in prs:
                logger.debug("Found PR %i updating %s: %s",
                             pr["number"], recipe, pr["title"])
            # update the PR if title or body changed
            pr = prs[0]
            args = {}
            if body != pr["body"]:
                args["body"] = body
            if title != pr["title"]:
                args["title"] = title
            if args:
                prs = await self.gh.modify_issue(number=pr['number'], **args)
                if prs:
                    logger.info("Updated PR %i updating %s to %s",
                                pr['number'], recipe, recipe.version)
                else:
                    logger.error("Failed to update PR %i with %s",
                                 pr['number'], args)
            else:
                logger.debug("Not updating PR %i updating %s - no changes",
                             pr['number'], recipe)

            raise self.UpdateInProgress(recipe)

        # check for matching closed PR (=> update rejected)
        prs = await self.gh.get_prs(from_branch=branch_name, state=self.gh.STATE.closed)
        if any(recipe.version in pr['title'] for pr in prs):
            raise self.UpdateRejected(recipe)

        # finally, create new PR
        pr = await self.gh.create_pr(title=title,
                                     from_branch=branch_name,
                                     body=body)
        if not pr:
            raise self.FailedToCreatePR(recipe)

        # set labels (can't do that in create_pr as they are part of issue API)
        await self.gh.modify_issue(number=pr['number'], labels=labels)

        logger.info("Created PR %i updating %s to %s", pr['number'], recipe, recipe.version)
        return recipe


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
        return recipe
