import abc
import inspect
import logging
import requests

from collections import defaultdict
from html.parser import HTMLParser
from pkg_resources import parse_version
from pprint import pprint
from urllib.parse import urljoin
from typing import List, Dict, Optional, Iterable, Mapping, List, Tuple, Any

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
re_capgroup = re.compile(r"\(\?P<(\w+)>(?>[^()]+|\\\(|\\\)|(\((?>[^()]+|\\\(|\\\)|(?2))*\)))*\)")


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
    return re.sub(re_capgroup, replace, pattern)


def get_meta_urls(meta: Mapping) -> Iterable[str]:
    """Extract all source URLs from parsed meta.yaml

    - The source key may not exist, be a list or a dict
    - The url key may not exist, be a list or a dict
    - Multiple urls in the url key indicate alternative download locations
    - Multiple sources indicate additional files
    """
    sources = meta.get("source", [])
    if isinstance(sources, Mapping):
        sources = [sources]
    for source in sources:
        urls = source.get("url", [])
        if isinstance(urls, str):
            urls = [urls]
        yield from urls


def update_version(recipe_folder: str, recipe_dir: str) -> None:
    """
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
    stats = []
    if not recipe_dir.startswith(recipe_folder):
        logger.error("Something went wrong: %s not prefix of %s", recipe_dir, recipe_folder)
        stats += ["ERROR_INTERNAL"]
        return stats

    is_sub_recipe = recipe_dir[len(recipe_folder):].strip("/").count("/") > 0

    jinja_vars = {
        "cran_mirror": "https://cloud.r-project.org"
    }
    meta = utils.load_meta_fast(recipe_dir, jinja_vars)  # this is still pretty slow
    watchcfg = meta.get("extra", {}).get("watch", {})

    if is_sub_recipe:
        stats += ["SUBRECIPE"]
        if watchcfg.get("enable", False):
            logger.debug("Processing explicitly enabled subrecipe")
            stats += ["SUBRECIPE_ENABLED"]
        else:
            stats += ["SUBRECIPE_SKIPPED"]
            return stats

    version = meta.get("package", {}).get("version")
    if not version:
        logger.error("Package %s has no version?!", recipe_dir)
        stats += ["ERROR_NO_VERSION"]
        return stats

    logger.debug("Checking for updates to %s - %s", recipe_dir, version)

    sources = meta.get("source", [])
    if not sources:
        logger.error("Package %s has no sources?", recipe_dir)
        stats += ["ERROR_NO_SOURCES"]
        return stats
    if isinstance(sources, Mapping):
        sources = [sources]
    else:
        stats += ["MULTISOURCE"]

    replace_map = {}
    for n, source in enumerate(sources):
        urls = source.get("url")
        if isinstance(urls, str):
            urls = [urls]
        if not urls:
            logger.error("Package %s has no url(s) in source %i", recipe_dir, n+1)
            stats += ["ERROR_NO_URLS"]
            continue
        version_map = defaultdict(dict)
        for url in urls:
            hoster = Hoster.select_hoster(url)
            if hoster:
                versions = hoster.get_versions()
                for vers, data in versions.items():
                    version_map[vers][url] = data
            else:
                logger.debug("Failed to parse url '%s'", url)
                match = re.search(r"://([^/]+)/", url)
                if match:
                    stats += [f"UNKOWN_URL_{match.group(1)}"]
                else:
                    stats += ["UNKNOWN_URL"]
                return stats

        if not version_map:
            logger.debug("Failed to parse any url in %s", recipe_dir)
            continue

        latest = max(version_map.keys(), key=lambda x: VersionOrder(x))

        if version == latest:
            logger.debug("Recipe %s is up to date", recipe_dir)
            stats += ["OK"]
        else:
            logger.info("Recipe %s has a new version %s => %s", recipe_dir, version, latest)
            stats += ["UPDATE"]
        return stats


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
            setattr(typ, pat + "_regex", pattern)
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


class HTMLHoster(Hoster):
    """Base for Hosters handling release listings in HTML format"""

    class Parser(HTMLParser):
        def __init__(self, hoster):
            super().__init__()
            self.hoster = hoster
            self.versions: Mapping = defaultdict(list)

        def handle_starttag(self, tag: str, attrs: List[Tuple[str, str]]) -> None:
            if tag == "a":
                for key, val in attrs:
                    if key == "href":
                        self.handle_href(val)
                        break

        def handle_href(self, href: str) -> None:
            match = self.hoster.link_re.search(href)
            if match:
                res = match.groupdict()
                res["link"] = urljoin(self.hoster.url, href)
                self.versions[res["version"]].append(res)

        def error(self, message: str) -> None:
            logger.debug("Error parsing HTML: %s", message)

    def __init__(self, url, data):
        self.data = data.groupdict()
        self.url = self.releases_format.format(**self.data)
        self.versions: Mapping = defaultdict(list)
        super().__init__(url)
    
    def get_versions(self) -> Mapping:
        logger.debug("Loading page '%s'", self.url)
        page = requests.get(self.url)
        logger.debug("done loading (%i bytes)", len(page.text))
        parser = self.Parser(self)
        parser.feed(page.text)
        return parser.versions


class FeedHoster(Hoster):
    pass


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
