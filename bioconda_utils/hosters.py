"""Check package URLs for updates

Subclasses of `Hoster` define how to handle each hoster. Hosters are
selected by regex matching each source URL in a recipe. The
`HTMLHoster` provides parsing for hosting sites listing new
releases in HTML format (probably covers most). Adding a hoster is
as simple as defining a regex to match the existing source URL, a
formatting string creating the URL of the relases page and a regex
to match links and extract their version.

- We need to use `regex` rather than `re` to allow recursive matching
  to manipulate capture groups in URL patterns as
  needed. (Technically, we could avoid this using a Snakemake wildcard
  type syntax to define the patterns - implementers welcome).

"""


import abc
import inspect
import json
import logging

from html.parser import HTMLParser
from itertools import chain
from typing import Dict, List, Match, Mapping, Pattern, Set, Tuple, Optional
from urllib.parse import urljoin

import regex as re


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


#: Matches named capture groups
#: This is so complicated because we need to parse matched, not-escaped
#: parentheses to determine where the clause ends.
#: Requires regex package for recursion.
RE_CAPGROUP = re.compile(r"\(\?P<(\w+)>(?>[^()]+|\\\(|\\\)|(\((?>[^()]+|\\\(|\\\)|(?2))*\)))*\)")
RE_REFGROUP = re.compile(r"\(\?P=(\w+)\)")

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
            return vals[name] or ""
        return match.group(0)
    res = re.sub(RE_CAPGROUP, replace, pattern)
    res = re.sub(RE_REFGROUP, replace, res)
    return res


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
        if not typ.__name__.startswith("Custom"):
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
                new_pattern = new_pattern.format_map(
                    {k: v.rstrip("$") for k, v in patterns.items()})
            patterns[pat] = pattern
            # repair duplicate capture groups:
            pattern = dedup_named_capture_group(pattern)
            # save parsed and compiled pattern
            setattr(typ, pat + "_pattern_compiled", pattern)
            logger.debug("%s Pattern %s = %s", typ.__name__, pat, pattern)
            setattr(typ, pat + "_re", re.compile(pattern))

        return typ

    @classmethod
    def select_hoster(mcs, url: str, config: Dict[str, str]) -> Optional["Hoster"]:
        """Select `Hoster` able to handle **url**

        Returns: `Hoster` or `None`
        """
        logger.debug("Matching url '%s'", url)
        for hoster_type in mcs.hoster_types:
            hoster = hoster_type.try_make_hoster(url, config)
            if hoster:
                return hoster
        return None


class Hoster(metaclass=HosterMeta):
    """Hoster Baseclass"""

    #: matches upstream version
    #: - begins with a number
    #: - then only numbers, characters or one of -, +, ., :, ~
    #: - at most 31 characters length (to avoid matching checksums)
    #: - accept v or r as prefix if after slash, dot, underscore or dash
    version_pattern: str = r"(?:(?<=[/._-])[rv])?(?P<version>\d[\da-zA-Z\-+\.:\~_]{0,30})"

    #: matches archive file extensions
    ext_pattern: str = r"(?P<ext>(?i)\.(?:(?:(tar\.|t)(?:xz|bz2|gz))|zip|jar))"

    #: named patterns that will change with a version upgrade
    exclude = ['version']

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
        self.vals = {k: v or "" for k, v in match.groupdict().items()}
        if isinstance(self.releases_format, str):
            self.releases_format = [self.releases_format]
        self.releases_urls = [
            template.format_map(self.vals)
            for template in self.releases_format
        ]
        logger.debug("%s matched %s with %s", self.__class__.__name__, url, self.vals)

    @classmethod
    def try_make_hoster(cls, url: str, config: Dict[str, str]) -> Optional["Hoster"]:
        """Creates hoster if **url** is matched by its **url_pattern**"""
        if config:
            try:
                cls = type("Customized"+cls.__name__,
                           (cls,),
                           {key+"_pattern":val for key, val in config.items()})
            except KeyError:
                logger.debug("Overrides invalid for %s - skipping", cls.__name__)
                return None

        match = cls.url_re.search(url)
        if match:
            return cls(url, match)
        return None

    @classmethod
    @abc.abstractmethod
    def get_versions(cls, scanner) -> List[Mapping[str, str]]:
        ""


class HrefParser(HTMLParser):
    """Extract link targets from HTML"""
    def __init__(self, link_re: Pattern[str]) -> None:
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

    async def get_versions(self, scanner):
        exclude = set(self.exclude)
        vals = {key: val
                for key, val in self.vals.items()
                if key not in exclude}
        link_pattern = replace_named_capture_group(self.link_pattern_compiled, vals)
        link_re = re.compile(link_pattern)
        result = []
        for url in self.releases_urls:
            parser = HrefParser(link_re)
            parser.feed(await scanner.get_text_from_url(url))
            for match in parser.matches:
                match["link"] = urljoin(url, match["href"])
                match["releases_url"] = url
                match["vals"] = vals
                match["hoster"] = self.__class__.__name__
                result.append(match)
        return result


class FTPHoster(Hoster):
    async def get_versions(self, scanner):
        exclude = set(self.exclude)
        vals = {key: val
                for key, val in self.vals.items()
                if key not in exclude}
        link_pattern = replace_named_capture_group(self.link_pattern_compiled, vals)
        link_re = re.compile(link_pattern)
        result = []
        for url in self.releases_urls:
            files = await scanner.get_ftp_listing(url)
            for fn in files:
                match = link_re.search(fn)
                if match:
                    data = match.groupdict()
                    data['fn'] = fn
                    data['link'] = "ftp://" + vals['host'] + fn
                    data['releases_url'] = url
                    result.append(data)
        return result

    version_pattern = r"(?:(?<=[/._-])[rv])?(?P<version>\d[\da-zA-Z\-+\.:\~_]{0,30}?)"
    host_pattern = r"(?P<host>[-_.\w]+)"
    path_pattern = r"(?P<path>[-_/.\w]+/)"
    package_pattern = r"(?P<package>[-_\w]+)"
    suffix_pattern = r"(?P<suffix>([-_](lin|linux|Linux|x64|x86|src|64|OSX))*)"
    link_pattern = "{path}{package}{version}{suffix}{ext}"
    url_pattern = r"ftp://{host}/{link}"
    releases_format = "ftp://{host}/{path}"


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
            if match["version"] == self.vals["version"]:
                break
        else:  # version not in list
            return matches
        return matches[:num+1]


class GithubBase(OrderedHTMLHoster):
    exclude = ['version', 'fname']
    account_pattern = r"(?P<account>[-\w]+)"
    project_pattern = r"(?P<project>[-.\w]+)"
    prefix_pattern = r"(?P<prefix>[-_./\w]+?)"
    suffix_pattern = r"(?P<suffix>[-_](lin)?)"
    #tag_pattern = "{prefix}??{version}{suffix}??"
    tag_pattern = "{prefix}??{version}"
    url_pattern = r"github\.com{link}"
    fname_pattern = r"(?P<fname>[^/]+)"
    releases_format = "https://github.com/{account}/{project}/releases"


class GithubRelease(GithubBase):
    """Matches release artifacts uploaded to Github"""
    link_pattern = r"/{account}/{project}/releases/download/{tag}/{fname}{ext}?"


class GithubTag(GithubBase):
    """Matches GitHub repository archives created automatically from tags"""
    link_pattern = r"/{account}/{project}/archive/{tag}{ext}"
    releases_format = "https://github.com/{account}/{project}/tags"


class GithubReleaseAttachment(GithubBase):
    """Matches release artifacts uploaded as attachment to release notes"""
    link_pattern = r"/{account}/{project}/files/\d+/{tag}{ext}"


class GithubRepoStore(GithubBase):
    """Matches release artifacts stored in a github repo"""
    branch_pattern = r"(master|[\da-f]{40})"
    subdir_pattern = r"(?P<subdir>([-._\w]+/)+)"
    link_pattern = r"/{account}/{project}/blob/master/{subdir}{tag}{ext}"
    url_pattern = (r"(?:(?P<raw>raw\.githubusercontent)|github)\.com/"
                   r"{account}/{project}/(?(raw)|(?:(?P<blob>blob/)|raw/))"
                   r"{branch}/{subdir}?{tag}{ext}(?(blob)\?raw|)")
    #releases_format = "https://github.com/{account}/{project}/tree/master/{subdir}{prefix}{version}{suffix}{ext}"
    releases_format = "https://github.com/{account}/{project}/tree/master/{subdir}"

class Bioconductor(HTMLHoster):
    """Matches R packages hosted at Bioconductor"""
    link_pattern = r"/src/contrib/(?P<package>[^/]+)_{version}{ext}"
    section_pattern = r"/(bioc|data/annotation|data/experiment)"
    url_pattern = r"bioconductor.org/packages/(?P<bioc>[\d\.]+){section}{link}"
    releases_format = "https://bioconductor.org/packages/{bioc}/bioc/html/{package}.html"


class CargoPort(HTMLHoster):
    """Matches source backup urls created by cargo-port"""
    os_pattern = r"_(?P<os>src_all|linux_x86|darwin_x86)"
    link_pattern = r"(?P<package>[^/]+)_{version}{os}{ext}"
    url_pattern = r"depot.galaxyproject.org/software/(?P<package>[^/]+)/{link}"
    releases_format = "https://depot.galaxyproject.org/software/{package}"


class SourceForge(HTMLHoster):
    """Matches packages hosted at SourceForge"""
    project_pattern = r"(?P<project>[-\w]+)"
    subproject_pattern = r"((?P<subproject>[-\w%]+)/)?"
    baseurl_pattern = r"sourceforge\.net/project(s)?/{project}/(?(1)files/|){subproject}"

    package_pattern = r"(?P<package>[-\w_\.+]*?[a-zA-Z+])"
    type_pattern = r"(?P<type>((linux|x?(64|86)|src|source|all|core|java\d?)[-_.])*)"
    type2_pattern = type_pattern.replace("type", "type2")
    sep_pattern = r"(?P<sep>[-_.]?)"  # separator between package name and version
    filename_pattern = "{package}{sep}({type2}{sep})?{version}({sep}{type})?{ext}"

    url_pattern = r"{baseurl}{filename}"
    link_pattern = r"{baseurl}{filename}"
    releases_format = "https://sourceforge.net/projects/{project}/files/"


class JSONHoster(Hoster):
    """Base for Hosters handling release listings in JSON format"""
    async def get_versions(self, scanner):
        result = []
        for url in self.releases_urls:
            text = await scanner.get_text_from_url(url)
            data = json.loads(text)
            matches = self.get_versions_from_json(data)
            for match in matches:
                match['releases_url'] = url
            result.extend(matches)
        return result
    link_pattern = "https://{url}"


class PyPi(JSONHoster):
    def get_versions_from_json(self, data):
        latest = data["info"]["version"]
        for rel in data["releases"][latest]:
            if rel["packagetype"] == "sdist":
                rel["link"] = rel["url"]
                rel["version"] = latest
                return [rel]
        return []

    releases_format = "https://pypi.org/pypi/{package}/json"
    package_pattern = r"(?P<package>[\w\-\.]+)"
    source_pattern = r"{package}[-_]{version}{ext}"
    hoster_pattern = (r"(?P<hoster>"
                      r"files.pythonhosted.org/packages|"
                      r"pypi.python.org/packages|"
                      r"pypi.io/packages)")
    url_pattern = r"{hoster}/.*/{source}"


class Bioarchive(JSONHoster):
    def get_versions_from_json(self, data):
        try:
            latest = data["info"]["Version"]
            vals = {key: val
                    for key, val in self.vals.items()
                    if key not in self.exclude}
            vals['version'] = latest
            link = replace_named_capture_group(self.link_pattern, vals)
            return [{
                "link": link,
                "version": latest,
            }]
        except KeyError:
            return []

    releases_format = "https://bioarchive.galaxyproject.org/api/{package}.json"
    package_pattern = r"(?P<package>[-\w.]+)"
    url_pattern = r"bioarchive.galaxyproject.org/{package}_{version}{ext}"


class CPAN(JSONHoster):
    def get_versions_from_json(self, data):
        try:
            version = {
                'link': data['download_url'],
                'version': str(data['version']),
            }
            return [version]
        except KeyError:
            return []

    package_pattern = r"(?P<package>[-\w.+]+)"
    author_pattern = r"(?P<author>[A-Z]+)"
    url_pattern = r"(www.cpan.org|cpan.metacpan.org|search.cpan.org/CPAN)/authors/id/./../{author}/([^/]+/|){package}-v?{version}{ext}"
    releases_format = "https://fastapi.metacpan.org/v1/release/{package}"


class CRAN(JSONHoster):
    def get_versions_from_json(self, data):
        res = []
        versions = list(set((str(data["latest"]), self.vals["version"])))
        for vers in versions:
            if vers not in data['versions']:
                continue
            vdata = data['versions'][vers]
            version = {
                'link': '',
                'version': vers,
                'depends': {
                    "r-" + pkg.lower() if pkg != 'R' else 'r-base':
                    spec.replace(" ", "").replace("\n","")
                    for pkg, spec in chain(vdata.get('Depends', {}).items(),
                                           vdata.get('Imports', {}).items())
                }
            }
            res.append(version)
        return res

    package_pattern = r"(?P<package>[\w.]+)"
    url_pattern = (r"r-project\.org/src/contrib"
                   r"(/Archive)?/{package}(?(1)/{package}|)"
                   r"_{version}{ext}")
    releases_format = "https://crandb.r-pkg.org/{package}/all"


class BitBucketBase(OrderedHTMLHoster):
    account_pattern = r"(?P<account>[-\w]+)"
    project_pattern = r"(?P<project>[-.\w]+)"
    prefix_pattern = r"(?P<prefix>[-_./\w]+?)??"
    url_pattern = r"bitbucket\.org{link}"


class BitBucketTag(BitBucketBase):
    link_pattern = "/{account}/{project}/get/{prefix}{version}{ext}"
    releases_format = ["https://bitbucket.org/{account}/{project}/downloads/?tab=tags",
                       "https://bitbucket.org/{account}/{project}/downloads/?tab=branches"]


class BitBucketDownload(BitBucketBase):
    link_pattern = "/{account}/{project}/downloads/{prefix}{version}{ext}"
    releases_format = "https://bitbucket.org/{account}/{project}/downloads/?tab=downloads"


class GitlabTag(OrderedHTMLHoster):
    account_pattern = r"(?P<account>[-\w]+)"
    subgroup_pattern = r"(?P<subgroup>(?:/[-\w]+|))"
    project_pattern = r"(?P<project>[-.\w]+)"
    link_pattern = r"/{account}{subgroup}/{project}/(repository|-/archive)/{version}/(archive|{project}-{version}){ext}"
    url_pattern = r"gitlab\.com{link}"
    releases_format = "https://gitlab.com/{account}{subgroup}/{project}/tags"


logger.info(f"Hosters loaded: %s", [h.__name__ for h in HosterMeta.hoster_types])
