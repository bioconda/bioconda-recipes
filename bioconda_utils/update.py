"""
Scans for package updates
"""

import abc
import asyncio
import inspect
import logging

from collections import defaultdict, Counter
from html.parser import HTMLParser
from urllib.parse import urljoin
#from pkg_resources import parse_version
from pprint import pprint
from typing import List, Dict, Optional, Iterable, Mapping, List, Tuple, Any
from concurrent.futures import ThreadPoolExecutor
from hashlib import sha256

import aiohttp
import backoff

from tqdm import tqdm

import regex as re

from conda.models.version import VersionOrder

from . import utils

logger = logging.getLogger(__name__)

"""
 - similar to pygments lexers to add more parsers
 - from URL and VERSION detect RELEASE_URL and select appropriate downloads
 - understand about
    - multiple meta.yaml per package for stable release branches
    - multiple upstream source packages
    - alternate download locations
 - configurable via meta.yaml to allow for funky schemes

 - think about debian-epoch style numbering

"""


#: Matches named capture groups
#: This is so complicated because we need to parse matched, not-escaped parentheses to
#: determine where the clause ends.
#: Requires regex package for recursion.
RE_CAPGROUP = re.compile(r"\(\?P<(\w+)>(?>[^()]+|\\\(|\\\)|(\((?>[^()]+|\\\(|\\\)|(?2))*\)))*\)")


def dedup_named_capture_group(pattern):
    """Replaces repetitions of capture groups with matches to first instance"""
    seen = set()

    def replace(match):
        name = match.group(1)
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


class Scanner(object):
    """Scans recipes for updates

    Arguments:
      recipe_folder: location of recipe directories
      packages: glob pattern to select recipes
      config: config.yaml (unused)
    """

    #: Defaults for Jinja2 rendering of meta.yaml files
    jinja_vars = {
        "cran_mirror": "https://cloud.r-project.org"
    }

    def __init__(self, recipe_folder, packages, config):
        self.config = config
        #: folder containing recipes
        self.recipe_folder = recipe_folder
        #: list of recipe folders to scan
        self.recipes = list(utils.get_recipes(self.recipe_folder, packages))
        try:  # get or create loop (threads don't have one)
            self.loop = asyncio.get_event_loop()
        except RuntimeError:
            self.loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.loop)
        #: executor for running local io
        self.io_exc = ThreadPoolExecutor()
        #: semaphore to limit parallelism in io_exc
        self.io_sem = asyncio.Semaphore(20)
        #: counter to gather stats on various states
        self.stats = Counter()
        #: aiohttp session (only exists while running)
        self.session = None
        #: failed urls - for later inspection
        self.failed_urls = []

    def run(self):
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
        with open("failed_urls.txt", "w") as out:
            out.write("\n".join(self.failed_urls))
        return task.result()

    async def _async_run(self):
        """Runner within async loop"""
        async with aiohttp.ClientSession() as session:
            self.session = session
            coros = [
                asyncio.ensure_future(
                    self.try_update_version(recipe_dir)
                )
                for recipe_dir in self.recipes
            ]
            try:
                with tqdm(asyncio.as_completed(coros), total=len(coros)) as t:
                    for coro in t:
                        await coro
            except asyncio.CancelledError:
                for coro in coros:
                    coro.cancel()
                await asyncio.wait(coros)

    async def try_update_version(self, recipe_dir):
        """Wrapper around `update_version` catching and logging exceptions"""
        try:
            return await self.update_version(recipe_dir)
        except asyncio.CancelledError:
            return
        except Exception as e:
            logger.exception("while scanning %s %s", self.recipe_folder, recipe_dir)

    async def load_meta(self, recipe_dir):
        """Loads a meta.yaml async in one of the io executors"""
        async with self.io_sem:
            return await self.loop.run_in_executor(
                self.io_exc, utils.load_meta_fast, recipe_dir, self.jinja_vars)

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=10,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_text_from_url(self, url):
        """Returns text from http URLjoin

        - On non-permanent errors (429, 502, 503, 504), the GET is retried 10 times with
        increasing wait times according to fibonacci series.
        - Permanent errors raise a ClientResponseError
        """
        async with self.session.get(url) as resp:
            resp.raise_for_status()
            return await resp.text()

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=10,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_checksum_from_url(self, url, desc):
        checksum = sha256()
        async with self.session.get(url) as resp:
            resp.raise_for_status()
            size = int(resp.headers.get("Content-Length", 0))
            with tqdm(total=size, unit='B', unit_scale=True, unit_divisor=1024,
                      desc=desc, miniters=1, leave=False) as t:
                while True:
                    block = await resp.content.read(1024*64)
                    if not block:
                        break
                    checksum.update(block)
                    t.update(len(block))
        return checksum.hexdigest()


    async def update_version(self, recipe_dir: str) -> None:
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
        if not recipe_dir.startswith(self.recipe_folder):
            logger.error("Something went wrong: %s not prefix of %s", recipe_dir, self.recipe_folder)
            self.stats["ERROR_INTERNAL"] += 1
            return

        meta = await self.load_meta(recipe_dir)

        watchcfg = meta.get("extra", {}).get("watch", {})
        is_sub_recipe = recipe_dir[len(self.recipe_folder):].strip("/").count("/") > 0
        version = meta.get("package", {}).get("version")
        sources = meta.get("source", [])

        logger.debug("Checking for updates to %s - %s", recipe_dir, version)

        if is_sub_recipe:
            if watchcfg.get("enable", False):
                logger.debug("Processing explicitly enabled subrecipe")
                self.stats["SUBRECIPE_ENABLED"] += 1
            else:
                self.stats["SUBRECIPE_SKIPPED"] += 1
                return

        if not version:
            logger.error("Package %s has no version?!", recipe_dir)
            self.stats["ERROR_NO_VERSION"] += 1
            return

        if not sources:
            logger.error("Package %s has no sources?", recipe_dir)
            self.stats["ERROR_NO_SOURCES"] += 1
            return

        if isinstance(sources, Mapping):
            sources = [sources]
        else:
            self.stats["MULTISOURCE"] += 1
            logger.error("Package %s is multi-source", recipe_dir)

        replace_map = {}
        for n, source in enumerate(sources):
            urls = source.get("url")
            if isinstance(urls, str):
                urls = [urls]
            if not urls:
                logger.error("Package %s has no url(s) in source %i", recipe_dir, n+1)
                self.stats["ERROR_NO_URLS"] += 1
                continue

            version_map = defaultdict(dict)
            for url in urls:
                hoster = Hoster.select_hoster(url)
                if not hoster:
                    logger.debug("Failed to parse url '%s'", url)
                    self.failed_urls += [url]

                    match = re.search(r"://([^/]+)/", url)
                    if match:
                        self.stats[f"UNKOWN_URL_{match.group(1)}"] += 1
                    else:
                        self.stats["UNKNOWN_URL"] += 1
                    return
                logger.debug("Scanning with %s", hoster.__class__.__name__)
                try:
                    versions = await hoster.get_versions(self)
                    for match in versions:
                        version_map[match["version"]][url] = match
                except aiohttp.ClientResponseError as e:
                    self.stats[f"HTTP_{e.code}"] += 1
                    logger.debug("HTTP %s when getting %s", e, url)

            if not version_map:
                logger.debug("Failed to parse any url in %s", recipe_dir)
                continue

            latest = max(version_map.keys(), key=lambda x: VersionOrder(x))

            if version == latest:
                continue
            replace_map.update(version_map[latest])

        if not replace_map:
            logger.debug("Recipe %s is up to date", recipe_dir)
            self.stats["OK"] += 1
            return

        logger.info("Recipe %s has a new version %s => %s", recipe_dir, version, latest)
        self.stats["UPDATE"] += 1

        for n, fn in enumerate(replace_map):
            link = replace_map[fn]["link"]
            checksum = await self.get_checksum_from_url(link, f"{recipe_dir} [{n}]")
            replace_map[fn]["sha256"] = checksum
        logger.warning(replace_map)


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
