"""
Scans for package updates
"""

import abc
import asyncio
import inspect
import logging
import os

from collections import defaultdict, Counter
from html.parser import HTMLParser
from urllib.parse import urljoin
from pkg_resources import parse_version
from pkg_resources.extern.packaging.version import LegacyVersion
from pprint import pprint
from typing import List, Dict, Optional, Iterable, Mapping, List, Tuple, Any, Set
from concurrent.futures import ThreadPoolExecutor
from hashlib import sha256

import aiohttp
import backoff
import yaml

from tqdm import tqdm

import regex as re

from conda.models.version import VersionOrder

from . import utils

logger = logging.getLogger(__name__)


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
        else:
            seen.add(name)
            return match.group(0)
    return re.sub(RE_CAPGROUP, replace, pattern)


def replace_named_capture_group(pattern, vals: Dict[str,str]):
    """Replaces capture groups with values from **vals**"""
    def replace(match):
        name = match.group(1)
        if name in vals:
            return vals[name]
        else:
            return match.group(0)
    return re.sub(RE_CAPGROUP, replace, pattern)


class Recipe(object):
    """Represents a recipe"""
    def __init__(self, recipe_dir, recipe_folder):
        if not recipe_dir.startswith(recipe_folder):
            raise RuntimeError(f"{recipe_folder} is not prefix of {recipe_dir}")
        self.dir = recipe_dir
        self.basedir = recipe_folder
        self.reldir = recipe_dir[len(recipe_folder):].strip("/")

        # Will be filled in by LoadMeta Filter
        self.version = None
        self.name = None
        self.config = None
        self.meta = None
        self.meta_yaml = None

    def __str__(self):
        return self.reldir


class Filter(abc.ABC):
    """Function object type called by Scanner"""
    def __init__(self, scanner: "Scanner") -> None:
        self.scanner = scanner

    @abc.abstractmethod
    async def apply(self, recipe: Recipe) -> bool:
        """Process a recipe. Returns False if processing should stop"""

    def finalize(self) -> None:
        """Called at the end of a run"""


class Scanner(object):
    """Scans recipes and applies filters in asyncio loop

    Arguments:
      recipe_folder: location of recipe directories
      packages: glob pattern to select recipes
      config: config.yaml (unused)
    """

    def __init__(self, recipe_folder: str, packages: str, config: str) -> None:
        self.config = config
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
        self.filters: List[Filter] = [
            LoadMeta(self),
        ]

    def add(self, filter: Filter, *args, **kwargs) -> None:
        """Adds `Filter` to this `Scanner`"""
        self.filters.append(filter(self, *args, **kwargs))

    def run(self) -> bool:
        """Runs scanner

        This starts the asyncio loop and manages shutdown.
        """
        try:
            task = asyncio.ensure_future(self._async_run())
            self.loop.run_until_complete(task)
            logger.warning("Finished update")
        except KeyboardInterrupt:
            logger.error("Ctrl-C pressed - aborting...")
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
                with tqdm(asyncio.as_completed(coros), total=len(coros)) as t:
                    return all([await coro for coro in t])
            except asyncio.CancelledError:
                for coro in coros:
                    coro.cancel()
                await asyncio.wait(coros)
                return False

    async def process(self, recipe_dir):
        """Wrapper around `update_version` catching and logging exceptions"""
        try:
            recipe = Recipe(recipe_dir, self.recipe_folder)
            for filt in self.filters:
                if not await filt.apply(recipe):
                    return False
        except asyncio.CancelledError:
            return False
        except Exception as e:
            logger.exception("while scanning %s", recipe_dir)
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
                      desc=desc, miniters=1, leave=False, disable=None) as t:
                while True:
                    block = await resp.content.read(1024*1024)
                    if not block:
                        break
                    t.update(len(block))
                    await self.loop.run_in_executor(self.executor, checksum.update, block)
        return checksum.hexdigest()


class LoadMeta(Filter):
    """Loads the recipe's meta.yaml

    - Populates **recipe.meta**, **recipe.version**, **recipe.name** and **recipe.config**
    - Fails if **version** or **name** don't exist
    """
    #: Defaults for Jinja2 rendering of meta.yaml files
    jinja_vars = {
        "cran_mirror": "https://cloud.r-project.org"
    }
    async def apply(self, recipe):
        recipe.meta_yaml = await self.scanner.run_io(self.load_meta, recipe.dir)
        self.parse_meta(recipe, self.jinja_vars)
        try:
            recipe.version = str(recipe.meta["package"]["version"])
            recipe.name = recipe.meta["package"]["name"]
        except KeyError as ex:
            self.scanner_stats["BROKEN"] += 1
            logger.error("% missing %s?!", recipe, ex.args[0])
            return False
        recipe.config = recipe.meta.get("extra", {}).get("watch", {})
        return True

    @staticmethod
    def load_meta(recipe_dir):
        path = os.path.join(recipe_dir, "meta.yaml")
        with open(path, "r", encoding="utf-8") as meta_yaml:
            return meta_yaml.read()

    @staticmethod
    def parse_meta(recipe, jinja_vars):
        template = utils.JINJA_ENV.from_string(recipe.meta_yaml)
        recipe.meta = yaml.load(template.render(jinja_vars))

class ExcludeOtherChannel(Filter):
    """Filters recipes matching packages in other **channels**"""
    def __init__(self, scanner: "Scanner", channels, cache):
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
    def __init__(self, scanner: "Scanner", always=False):
        super().__init__(scanner)
        self.always_exclude = always

    async def apply(self, recipe):
        is_subrecipe = recipe.reldir.count("/") > 0
        enabled = recipe.config.get("enable", False) == True
        skip = is_subrecipe and not (enabled and not self.always_exclude)
        if skip:
            logger.debug("Skipping subrecipe %s", recipe)
            self.scanner.stats["SKIPPED_SUBRECIPE"] += 1
        return not skip


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

    async def apply(self, recipe: Recipe) -> None:
        logger.debug("Checking for updates to %s - %s", recipe, recipe.version)

        sources = recipe.meta.get("source")
        if not sources:
            logger.info("Recipe %s is a metapackage (no sources)", recipe)
            self.scanner.stats["METAPACKAGE"] += 1
            return False

        if isinstance(sources, Mapping):
            versions = await self.get_versions(recipe, sources, 1)
            if versions:
                latest = self.select_version(recipe.version, versions.keys())
            else:
                return
        else:
            self.scanner.stats["MULTISOURCE"] += 1
            logger.info("Recipe %s is multi-source", recipe)
            # FIXME: handle multisource
            #for n, source in enumerate(sources):
            #    self.update_source(sources, n)
            return

        if latest == recipe.version:
            logger.debug("Recipe %s is up to date", recipe)
            self.scanner.stats["OK"] += 1
            return

        logger.info("Recipe %s has a new version %s > %s", recipe, latest, recipe.version)
        self.scanner.stats["UPDATE"] += 1

        recipe.meta_yaml.replace(recipe.version, latest)

        #for n, fn in enumerate(replace_map):
        #    link = replace_map[fn]["link"]
        #    checksum = await self.scanner.get_checksum_from_url(link, f"{recipe} [{n}]")
        #    replace_map[fn]["sha256"] = checksum
        #logger.warning(replace_map)

    async def get_versions(self, recipe, source, n):
        urls = source.get("url")
        if isinstance(urls, str):
            urls = [urls]
        if not urls:
            logger.info("Package %s has no url in source %i", recipe, n+1)
            self.scanner.stats["ERROR_NO_URLS"] += 1
            return

        version_map = defaultdict(dict)
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
            except aiohttp.ClientResponseError as e:
                self.scanner.stats[f"HTTP_{e.code}"] += 1
                logger.debug("HTTP %s when getting %s", e, url)

        if not version_map:
            logger.debug("Failed to parse any url in %s", recipe)
            return

        return version_map

    @staticmethod
    def select_version(current, versions):
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


class HosterMeta(abc.ABCMeta):
    """Meta-Class for Hosters

    By making Hosters classes of a metaclass, rather than instances of a class,
    we leave the option to add functions to a Hoster.
    """

    _hoster_types: List["HosterMeta"] = []

    def __new__(mcs, name, bases, attrs, **opts):
        """Creates Hoster classes

        - expands references among ``{var}_pattern`` attributes
        - compiles ``{var}_pattern`` attributes to ``{var}_re``
        - registers complete classes
        """
        typ = super().__new__(mcs, name, bases, attrs, **opts)

        if inspect.isabstract(typ):
            return typ
        mcs._hoster_types.append(typ)

        patterns = {attr.replace("_pattern", ""): getattr(typ, attr)
                    for attr in dir(typ) if attr.endswith("_pattern")}

        for pat in patterns:
            # expand pattern references:
            pattern = ""
            new_pattern = patterns[pat]
            while pattern != new_pattern:
                pattern = new_pattern
                new_pattern = pattern.format(**patterns)
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
        for hoster_type in mcs._hoster_types:
            hoster = hoster_type.try_make_hoster(url)
            if hoster:
                return hoster
        return None


class Hoster(object, metaclass=HosterMeta):
    """Hoster Baseclass"""

    #: matches upstream version
    version_pattern: str = r"(?P<version>\d[\-+\.:\~\da-zA-Z]*)"

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

    def __init__(self, data):
        pass

    @classmethod
    def try_make_hoster(cls, url: str) -> Optional["Hoster"]:
        """Creates hoster if **url** is matched by its **url_pattern**"""
        match = cls.url_re.search(url)
        if match:
            return cls(url, match)
        return None

    @classmethod
    @abc.abstractmethod
    def get_versions(cls) -> Mapping:
        ""


class HrefParser(HTMLParser):
    def __init__(self, link_re):
        super().__init__()
        self.link_re = link_re
        self.matches = []

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

    def __init__(self, url, match):
        self.orig_match = match
        self.releases_url = self.releases_format.format(**match.groupdict())
        super().__init__(url)

    async def get_versions(self, scanner) -> Mapping:
        exclude = set(["version"])
        vals = { key: val
                 for key, val in self.orig_match.groupdict().items()
                 if key not in exclude }
        link_pattern = replace_named_capture_group(self.link_pattern, vals)
        parser = HrefParser(re.compile(link_pattern))
        parser.feed(await scanner.get_text_from_url(self.releases_url))
        for match in parser.matches:
            match["link"] = urljoin(self.releases_url, match["href"])
        return parser.matches


class GithubRelease(HTMLHoster):
    link_pattern = "/(?P<account>[\w\-]*)/(?P<project>[\w\-]*)/releases/download/v?{version}/(?P<fname>[^/]+{ext})"
    url_pattern = "github.com{link}"
    releases_format = "https://github.com/{account}/{project}/releases"

class GithubTag(HTMLHoster):
    link_pattern = "/(?P<account>[\w\-]*)/(?P<project>[\w\-]*)/archive/v?{version}{ext}"
    url_pattern = "github.com{link}"
    releases_format = "https://github.com/{account}/{project}/tags"

class Bioconductor(HTMLHoster):
    link_pattern = "/src/contrib/(?P<package>[^/]+)_{version}{ext}"
    url_pattern = "bioconductor.org/packages/(?P<bioc>[\d\.]+)/bioc{link}"
    releases_format = "https://bioconductor.org/packages/{bioc}/bioc/html/{package}.html"


class DepotGalaxyProject(HTMLHoster):
    os_pattern = "_(?P<os>src_all|linux_x86|darwin_x86)"
    link_pattern = "(?P<package>[^/]+)_{version}{os}{ext}"
    url_pattern = "depot.galaxyproject.org/software/(?P<package>[^/]+)/{link}"
    releases_format = "https://depot.galaxyproject.org/software/{package}/"


logger.info(f"Hosters loaded: {[h.__name__ for h in HosterMeta._hoster_types]}")
