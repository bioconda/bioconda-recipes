"""
Conda Skeleton for Bioconductor Recipes
"""
import shutil
import tempfile
import configparser
from textwrap import dedent
import tarfile
import hashlib
import os
import re
from collections import OrderedDict
import logging

import bs4
import pyaml
import requests
import yaml
import networkx as nx
import itertools

from . import utils
from . import cran_skeleton

logger = logging.getLogger(__name__)

base_url = 'https://bioconductor.org/packages/'

# Packages that might be specified in the DESCRIPTION of a package as
# dependencies, but since they're built-in we don't need to specify them in
# the meta.yaml.
#
# Note: this list is from:
#
#   conda create -n rtest -c r r
#   R -e "rownames(installed.packages())"
BASE_R_PACKAGES = ["base", "compiler", "datasets", "graphics", "grDevices",
                   "grid", "methods", "parallel", "splines", "stats", "stats4",
                   "tcltk", "tools", "utils"]

# These CRAN packages directly or indirectly depend on X, requiring specialized
# build and test-time requirements as well as the extended container.
# These can be found here: https://github.com/search?p=2&q=cdt%28%27mesa-libgl-devel%27%29+user%3Aconda-forge+r-base&type=Code
# and here: https://github.com/search?l=YAML&q=r-rgl+user%3Aconda-forge&type=Code
CRAN_X_PACKAGES = set(["rgl", "tsdist", "tsclust", "plot3drgl", "pals", "longitudinaldata",
                       "bpca", "bcrocsurface", "feature", "pca3d", "forestfloor", "oceanview",
                       "clustersim", "hiver", "lidr", "mixomics", "snpls", "matlib", "qpcr"])

HERE = os.path.abspath(os.path.dirname(__file__))


class PackageNotFoundError(Exception):
    pass


class PageNotFoundError(Exception):
    pass


def bioconductor_versions():
    """
    Returns a list of available Bioconductor versions scraped from the
    Bioconductor site.
    """
    url = "https://bioconductor.org/config.yaml"
    response = requests.get(url)
    bioc_config = yaml.load(response.text)
    versions = list(bioc_config["r_ver_for_bioc_ver"].keys())
    # Handle semantic version sorting like 3.10 and 3.9
    versions = sorted(versions, key=lambda v: list(map(int, v.split('.'))), reverse=True)
    return versions


def latest_bioconductor_release_version():
    """
    Latest Bioconductor release version.
    """
    return bioconductor_versions()[1]


def latest_bioconductor_devel_version():
    """
    Latest Bioconductor version in development.
    """
    return bioconductor_versions()[0]


def bioconductor_tarball_url(package, pkg_version, bioc_version):
    """
    Constructs a url for a package tarball

    Parameters
    ----------
    package : str
        Case-sensitive Bioconductor package name

    pkg_version : str
        Bioconductor package version

    bioc_version : str
        Bioconductor release version
    """
    return (
        'http://bioconductor.org/packages/{bioc_version}'
        '/bioc/src/contrib/{package}_{pkg_version}.tar.gz'.format(**locals())
    )


def bioconductor_annotation_data_url(package, pkg_version, bioc_version):
    """
    Constructs a url for an annotation package tarball

    Parameters
    ----------
    package : str
        Case-sensitive Bioconductor package name

    pkg_version : str
        Bioconductor package version

    bioc_version : str
        Bioconductor release version
    """
    return (
        'http://bioconductor.org/packages/{bioc_version}'
        '/data/annotation/src/contrib/{package}_{pkg_version}.tar.gz'.format(**locals())
    )


def bioconductor_experiment_data_url(package, pkg_version, bioc_version):
    """
    Constructs a url for an experiment data package tarball

    Parameters
    ----------
    package : str
        Case-sensitive Bioconductor package name

    pkg_version : str
        Bioconductor package version

    bioc_version : str
        Bioconductor release version
    """
    return (
        'http://bioconductor.org/packages/{bioc_version}'
        '/data/experiment/src/contrib/{package}_{pkg_version}.tar.gz'.format(**locals())
    )


def bioarchive_url(package, pkg_version, bioc_version=None):
    """
    Constructs a url for the package as archived on bioaRchive

    Parameters
    ----------
    package : str
        Case-sensitive Bioconductor package name

    pkg_version : str
        Bioconductor package version

    bioc_version : str
        Bioconductor release version. Not used;, only included for API
        compatibility with other url funcs
    """
    return (
        'https://bioarchive.galaxyproject.org/{0}_{1}.tar.gz'
        .format(package, pkg_version)
    )


def cargoport_url(package, pkg_version, bioc_version=None):
    """
    Constructs a url for the package as archived on the galaxy cargo-port

    Parameters
    ----------
    package : str
        Case-sensitive Bioconductor package name

    pkg_version : str
        Bioconductor package version

    bioc_version : str
        Bioconductor release version. Not used;, only included for API
        compatibility with other url funcs
    """
    package = package.lower()
    return (
        'https://depot.galaxyproject.org/software/bioconductor-{0}/bioconductor-{0}_'
        '{1}_src_all.tar.gz'.format(package, pkg_version)
    )


def find_best_bioc_version(package, version):
    """
    Given a package version number, identifies which BioC version[s] it is in
    and returns the latest.

    If the package is not found, raises a PackageNotFound error.

    Parameters
    ----------
    package :
        Case-sensitive Bioconductor package name

    version :
        Bioconductor package version

    Returns None if no valid package found.
    """
    for bioc_version in bioconductor_versions():
        for kind, func in zip(
            ('package', 'data'),
            (
                bioconductor_tarball_url, bioconductor_annotation_data_url,
                bioconductor_experiment_data_url,
            ),
        ):
            url = func(package, version, bioc_version)
            if requests.head(url).status_code == 200:
                logger.debug('success: %s', url)
                logger.info(
                    'A working URL for %s==%s was identified for Bioconductor version %s: %s',
                    package, version, bioc_version, url)
                found_version = bioc_version
                return found_version
            else:
                logger.debug('missing: %s', url)
    raise PackageNotFoundError(
        "Cannot find any Bioconductor versions for {0}=={1}".format(package, version)
    )


def fetchPackages(bioc_version):
    """
    Return a dictionary of all bioconductor packages in a given release::

        {package: {Version: "version",
                   Depends: [list],
                   Suggests: [list],
                   MD5sum: "hash",
                   License: "foo",
                   Description: "Something...",
                   NeedsCompilation: boolean},
                  ...
        }
    """
    d = dict()
    packages_urls = [(os.path.join(base_url, bioc_version, 'bioc', 'VIEWS'), 'bioc'),
                     (os.path.join(base_url, bioc_version, 'data', 'annotation', 'VIEWS'), 'data/annotation'),
                     (os.path.join(base_url, bioc_version, 'data', 'experiment', 'VIEWS'), 'data/experiment')]
    for url, prefix in packages_urls:
        req = requests.get(url)
        if not req.ok:
            sys.exit("ERROR: Could not fetch {}!\n".format(url))
        for pkg in req.text.strip().split("\n\n"):
            pkgDict = dict()
            lastKey = None
            for line in pkg.split("\n"):
                if line.startswith(" "):
                    pkgDict[lastKey] += " {}".format(line.strip())
                    pkgDict[lastKey] = pkgDict[lastKey].strip()  # Prevent prepending a space when content begins on the next line
                elif ":" in line:
                    idx = line.index(":")
                    lastKey = line[:idx]
                    pkgDict[lastKey] = line[idx + 2:].strip()
            pkgDict['URLprefix'] = prefix.strip()
            d[pkgDict['Package']] = pkgDict
    return d


def packagesNeedingX(packages):
    """
    Return a set of all packages needing X. Packages needing X are defines as those that directly or indirectly require rgl.
    """
    depTree = nx.DiGraph()
    for p, meta in packages.items():
        p = p.lower()
        if p not in depTree:
            depTree.add_node(p)
        for field in ["Imports", "Depends", "LinkingTo"]:
            if field in meta:
                for dep in meta[field].split(","):
                    # This is a simplified form for BioCProjectPage._parse_dependencies
                    dep = dep.strip().split("(")[0].strip().lower()
                    if dep not in depTree:
                        depTree.add_node(dep)
                    depTree.add_edge(dep, p)
    Xset = set()
    for cxp in CRAN_X_PACKAGES:
        if cxp in depTree:
            for xp in itertools.chain(*nx.dfs_successors(depTree, cxp).values()):
                Xset.add(xp)
    return Xset


class BioCProjectPage(object):
    def __init__(self, package, bioc_version=None, pkg_version=None, packages=None):
        """
        Represents a single Bioconductor package page and provides access to
        scraped data.
        >>> x = BioCProjectPage('DESeq2')
        >>> x.tarball_url
        'http://bioconductor.org/packages/release/bioc/src/contrib/DESeq2_1.8.2.tar.gz'
        """
        self.base_url = base_url
        self.package = package
        self.package_lower = package.lower()
        self._md5 = None
        self._cached_tarball = None
        self._dependencies = None
        self.build_number = 0
        self.bioc_version = bioc_version
        self._pkg_version = pkg_version
        self._cargoport_url = None
        self._bioarchive_url = None
        self._tarball_url = None
        self._bioconductor_tarball_url = None
        self.is_data_package = False
        self.package_lower = package.lower()
        self.version = pkg_version
        self.extra = None
        self.needsX = False

        # If no version specified, assume the latest
        if not self.bioc_version:
            if not self._pkg_version:
                self.bioc_version = latest_bioconductor_release_version()
            else:
                self.bioc_version = find_best_bioc_version(self.package, self._pkg_version)

        # Fetch a list of all packages, so dependency versions can be calculated
        if not packages:
            self.packages = fetchPackages(self.bioc_version)
        else:
            self.packages = packages

        if package not in self.packages:
            raise PackageNotFoundError('{} does not exist in this bioconductor release!'.format(package))

        if not pkg_version:
            self.version = self.packages[package]['Version']
        self.depends_on_gcc = False

        # Determine the URL
        url = os.path.join(base_url, self.bioc_version, self.packages[package]['URLprefix'], 'html', package + '.html')
        request = requests.get(url)

        if not request:
            raise PageNotFoundError(
                'Could not find HTML page for {0.package}. Tried: '
                '{1}'.format(self, url))

        # Since we provide the "short link" we will get redirected. Using
        # requests allows us to keep track of the final destination URL,
        # which we need for reconstructing the tarball URL.
        self.url = request.url

        if self.packages[package]['URLprefix'] != 'bioc':
            self.is_data_package = True

    @property
    def bioarchive_url(self):
        """
        Returns the bioaRchive URL if one exists for this version of this
        package, otherwise returns None.
        """
        url = bioarchive_url(self.package, self.version, self.bioc_version)
        response = requests.head(url)
        if response.status_code == 200:
            return url

    @property
    def cargoport_url(self):
        """
        Returns the Galaxy cargo-port URL for this version of this package, if
        it exists.
        """
        url = cargoport_url(self.package, self.version, self.bioc_version)
        response = requests.head(url)
        if response.status_code == 404:
            # This is expected if this is a new package or an updated version.
            # Cargo Port will archive a working URL upon merging
            return
        elif response.status_code == 200:
            return url
        else:
            raise PageNotFoundError(
                "Unexpected error: {0.status_code} ({0.reason})".format(response))

    @property
    def bioconductor_tarball_url(self):
        """
        Return the url to the tarball from the bioconductor site.
        """
        url = os.path.join(base_url, self.bioc_version, self.packages[self.package]['URLprefix'], self.packages[self.package]['source.ver'])
        response = requests.head(url)
        if response.status_code == 200:
            return url

    @property
    def tarball_url(self):
        if not self._tarball_url:
            urls = [self.bioconductor_tarball_url,
                    self.bioarchive_url,
                    self.cargoport_url]
            for url in urls:
                if url is not None:
                    response = requests.head(url)
                    if response.status_code == 200:
                        self._tarball_url = url
                        return url

            logger.error(
                'No working URL for %s==%s in Bioconductor %s. '
                'Tried the following:\n\t' + '\n\t'.join(urls),
                self.package, self.version, self.bioc_version
            )

            if self._auto:
                find_best_bioc_version(self.package, self.version)

            if self._tarball_url is None:
                raise ValueError(
                    "No working URLs found for this version in any bioconductor version")
        return self._tarball_url

    @property
    def tarball_basename(self):
        return os.path.basename(self.tarball_url)

    @property
    def cached_tarball(self):
        """
        Downloads the tarball to the ``cached_bioconductor_tarballs`` dir if one
        hasn't already been downloaded for this package.

        This is because we need the whole tarball to determine which compilers
        are needed.
        """
        if self._cached_tarball:
            return self._cached_tarball
        cache_dir = os.path.join(tempfile.gettempdir(), 'cached_bioconductor_tarballs')
        if not os.path.exists(cache_dir):
            os.makedirs(cache_dir)
        fn = os.path.join(cache_dir, self.tarball_basename)
        if os.path.exists(fn):
            self._cached_tarball = fn
            return fn
        tmp = tempfile.NamedTemporaryFile(delete=False).name
        with open(tmp, 'wb') as fout:
            logger.info('Downloading {0} to {1}'.format(self.tarball_url, fn))
            response = requests.get(self.tarball_url)
            if response.status_code == 200:
                fout.write(response.content)
            else:
                raise PageNotFoundError(
                    'Unexpected error {0.status_code} ({0.reason})'.format(response))
        shutil.move(tmp, fn)
        self._cached_tarball = fn
        return fn

    @property
    def title(self):
        """
        The Title section fromt he VIEW file
        """
        return self.packages[self.package]['Title']

    @property
    def description(self):
        """
        The "Description" from the VIEW file
        """
        return self.packages[self.package]['Description']

    @property
    def license(self):
        return self.packages[self.package]['License']

    def license_file_location(self):
        """
        R ships with a number of license files that we can simply refer to.

        This supports: AGPL-3, Artistic-2.0, GPL-2, GPL-3, LGPL-2, LGPL-2.1, LGPL-3

        MIT, and 2/3 clause BSD licenses are provided as well, but those are just templates.

        Anything with GPL/LGPL in the name that doesn't otherwise match a lower version is assigned
        GPL-3/LGPL-3
        """
        license = self.license
        if "LICENSE" in license:
            return "LICENSE"

        licenses = {'GPL-2': '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-2',
                    'GPL (== 2)': '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-2',
                    'GPL (==2)': '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-2',
                    'GPL version 2': '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-2',
                    'AGPL-3': '{{ environ["PREFIX"] }}/lib/R/share/licenses/AGPL-3',
                    'Artisitic-2.0': '{{ environ["PREFIX"] }}/lib/R/share/licenses/Artistic-2.0',
                    'LGPL-2': '{{ environ["PREFIX"] }}/lib/R/share/licenses/LGPL-2',
                    'LGPL-2.1': '{{ environ["PREFIX"] }}/lib/R/share/licenses/LGPL-2.1'}

        if license in licenses:
            return licenses[license]

        if "LGPL" in license:
            return '{{ environ["PREFIX"] }}/lib/R/share/licenses/LGPL-3'

        if "GPL" in license:
            return '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-3'
        return None


    @property
    def imports(self):
        """
        List of "imports" from the VIEW file
        """
        try:
            return [i.strip() for i in self.packages[self.package]['Imports'].replace(' ', '').split(',')]
        except KeyError:
            return []

    @property
    def systemrequirements(self):
        """
        List of "SystemRequirements" from the VIEW file
        """
        try:
            print(self.packages[self.package]['SystemRequirements'])
            return self.packages[self.package]['SystemRequirements']
        except KeyError:
            return []

    @property
    def depends(self):
        """
        List of "depends" from the VIEW file
        """
        try:
            return [i.strip() for i in self.packages[self.package]['Depends'].replace(' ', '').split(',')]
        except KeyError:
            return []

    @property
    def linkingto(self):
        """
        List of "linkingto" from the VIEW file
        """
        try:
            return [i.strip() for i in self.packages[self.package]['LinkingTo'].replace(' ', '').split(',')]
        except KeyError:
            return []

    def _parse_dependencies(self, items):
        """
        The goal is to go from

        ['package1', 'package2', 'package3 (>= 0.1)', 'package4']

        to::

            [
                ('package1', ""),
                ('package2', ""),
                ('package3', " >=0.1"),
                ('package1', ""),
            ]

        """
        results = []
        for item in items:
            toks = [i.strip() for i in item.split('(')]
            if len(toks) == 1:
                results.append((toks[0], ""))
            elif len(toks) == 2:
                assert ')' in toks[1]
                toks[1] = toks[1].replace(')', '').replace(' ', '')
                results.append(tuple(toks))
            else:
                raise ValueError("Found {0} toks: {1}".format(len(toks), toks))
        return results

    def pin_version(self, name):
        """
        Given a package name, return the version pin string.

        For example, if version 1.2.3 is in the current bioconductor release,
        then return >=1.2.0,<1.3.0.

        The following have 2 digit versions:
          - BSgenome.Vvinifera.URGI.IGGP8X
          - DO.db
          - BSgenome.Vvinifera.URGI.IGGP12Xv0
          - BSgenome.Vvinifera.URGI.IGGP12Xv2
        """
        v = str(self.packages[name]['Version'])
        # There are a few packages with only major.minor versions!
        s = v.split(".")
        if len(s) == 3:
            return ">={}.{}.0,<{}.{}.0".format(s[0], s[1], s[0], int(s[1]) + 1)
        else:
            return "{}.{}".format(s[0], s[1])

    @property
    def dependencies(self):
        """

        """
        if self._dependencies:
            return self._dependencies

        dependency_mapping = {}

        # Sometimes a version is specified only in the `depends` and not in the
        # `imports`. We keep the most specific version of each.
        version_specs = list(
            set(
                self._parse_dependencies(self.imports) +
                self._parse_dependencies(self.depends) +
                self._parse_dependencies(self.linkingto)
            )
        )
        specific_r_version = False
        versions = {}
        for name, version in version_specs:
            if name in versions:
                if not versions[name] and version:
                    versions[name] = version
            else:
                versions[name] = version

        for name, version in sorted(versions.items()):
            # DESCRIPTION notes base R packages, but we don't need to specify
            # them in the dependencies.
            if name in BASE_R_PACKAGES:
                continue

            # Try finding the dependency on the bioconductor site; if it can't
            # be found then we assume it's in CRAN.
            if name in self.packages:
                prefix = 'bioconductor-'
                version = self.pin_version(name)
            else:
                prefix = 'r-'

            logger.info('{0:>12} dependency: name="{1}" version="{2}"'.format(
                {'r-': 'R', 'bioconductor-': 'BioConductor'}[prefix],
                name, version))

            # add padding to version string
            if version:
                version = " " + version

            # Some packages define a minimum version of R. In that case, we add
            # the dependency `r-base` for that version. Otherwise, R is
            # implied, and we make sure that r-base is added as a dependency at
            # the end.
            if name.lower() == 'r':

                # Had some issues with CONDA_R finding the right version if "r"
                # had version restrictions. Since we're generally building
                # up-to-date packages, we can just use "r".
                #

                # # "r >=2.5" rather than "r-r >=2.5"
                specific_r_version = True
                dependency_mapping[name.lower() + '-base'] = 'r-base'

            else:
                dependency_mapping[prefix + name.lower() + version] = name

        # Check SystemRequirements in the DESCRIPTION file to make sure
        # packages with such reqquirements are provided correct recipes.
        if (self.packages[self.package].get('SystemRequirements') is not None):
            logger.warning(
                "The 'SystemRequirements' {} are needed".format(
                    self.packages[self.package].get('SystemRequirements')) +
                " by the recipe for the package to work as intended."
            )

        if (
            (self.packages[self.package].get('NeedsCompilation', 'no') == 'yes') or
            (self.packages[self.package].get('LinkingTo', None) is not None)
        ):
            # Modified from conda_build.skeletons.cran
            #
            with tarfile.open(self.cached_tarball) as tf:
                need_f = any(f.name.lower().endswith(('.f', '.f90', '.f77')) for f in tf)
                if need_f:
                    need_c = True
                else:
                    need_c = any(f.name.lower().endswith('.c') for f in tf)
                need_cxx = any(
                    f.name.lower().endswith(('.cxx', '.cpp', '.cc', '.c++')) for f in tf)
                need_autotools = any(f.name.lower().endswith('/configure') for f in tf)
                if any((need_autotools, need_f, need_cxx, need_c)):
                    need_make = True
                else:
                    need_make = any(
                        f.name.lower().endswith(('/makefile', '/makevars')) for f in tf)
        else:
            need_c = need_cxx = need_f = need_autotools = need_make = False

        for name, version in sorted(versions.items()):
            if name in ['Rcpp', 'RcppArmadillo']:
                need_cxx = True

        if need_cxx:
            need_c = True

        self._cb3_build_reqs = {}
        if need_c:
            self._cb3_build_reqs['c'] = "{{ compiler('c') }}"
        if need_cxx:
            self._cb3_build_reqs['cxx'] = "{{ compiler('cxx') }}"
        if need_f:
            self._cb3_build_reqs['fortran'] = "{{ compiler('fortran') }}"
        if need_autotools:
            self._cb3_build_reqs['automake'] = 'automake'
        if need_make:
            self._cb3_build_reqs['make'] = 'make'

        # Add R itself
        if not specific_r_version:
            dependency_mapping['r-base'] = 'r-base'

        # Sometimes empty dependencies make it into the list from a trailing
        # comma in DESCRIPTION; remove them here.
        for k in list(dependency_mapping.keys()):
            if k == 'r-':
                dependency_mapping.pop(k)

        self._dependencies = dependency_mapping
        return self._dependencies

    @property
    def md5(self):
        """
        Calculate the md5 hash of the tarball so it can be filled into the
        meta.yaml.
        """
        return self.packages[self.package]['MD5sum']

    def pacified_text(self, section="Description"):
        """
        Linting will fail if ``GIT_``, ``HG_``, or ``SVN_`` appear in the description.
        This usually isn't an issue, except some microarray annotation packages
        include ``HG_`` in their summaries. The goal is to simply remove ``_`` in such
        cases.

        By default, this will pacify the Description section
        """
        description = self.packages[self.package][section]
        for vcs in ['HG', 'SVN', 'GIT']:
            description = description.replace('{}_'.format(vcs), '{} '.format(vcs))
        return description

    @property
    def meta_yaml(self):
        """
        Build the meta.yaml string based on discovered values.

        Here we use a nested OrderedDict so that all meta.yaml files created by
        this script have the same consistent format. Otherwise we're at the
        mercy of Python dict sorting.

        We use pyaml (rather than yaml) because it has better handling of
        OrderedDicts.

        However pyaml does not support comments, but if there are gcc and llvm
        dependencies then they need to be added with preprocessing selectors
        for ``# [linux]`` and ``# [osx]``.

        We do this with a unique placeholder (not a jinja or $-based
        string.Template) so as to avoid conflicting with the conda jinja
        templating or the ``$R`` in the test commands, and replace the text once
        the yaml is written.
        """

        version_placeholder = '{{ version }}'
        package_placeholder = '{{ name }}'
        package_lower_placeholder = '{{ name|lower }}'
        bioc_placeholder = '{{ bioc }}'

        def sub_placeholders(x):
            return (
                x
                .replace(self.version, version_placeholder)
                .replace(self.package, package_placeholder)
                .replace(self.package_lower, package_lower_placeholder)
                .replace(self.bioc_version, bioc_placeholder)
            )

        url = [
            sub_placeholders(u) for u in
            [
                # keep the one that was found
                self.bioconductor_tarball_url,
                # use the built URL, regardless of whether it was found or not.
                # bioaRchive and cargo-port cache packages but only after the
                # first recipe is built.
                bioarchive_url(self.package, self.version, self.bioc_version),
                cargoport_url(self.package, self.version, self.bioc_version),
            ]
            if u is not None
        ]

        DEPENDENCIES = sorted(self.dependencies)

        additional_run_deps = []
        if self.is_data_package:
            additional_run_deps.append('curl')

        d = OrderedDict((
            (
                'package', OrderedDict((
                    ('name', 'bioconductor-{{ name|lower }}'),
                    ('version', '{{ version }}'),
                )),
            ),
            (
                'source', OrderedDict((
                    ('url', url),
                    ('md5', self.md5),
                )),
            ),
            (
                'build', OrderedDict((
                    ('number', self.build_number),
                    ('rpaths', ['lib/R/lib/', 'lib/']),
                )),
            ),
            (
                'requirements', OrderedDict((
                    # If you don't make copies, pyaml sees these as the same
                    # object and tries to make a shortcut, causing an error in
                    # decoding unicode. Possible pyaml bug? Anyway, this fixes
                    # it.
                    ('host', DEPENDENCIES[:]),
                    ('run', DEPENDENCIES[:] + additional_run_deps),
                )),
            ),
            (
                'test', OrderedDict((
                    (
                        'commands', ['''$R -e "library('{{ name }}')"''']
                    ),
                )),
            ),
            (
                'about', OrderedDict((
                    ('home', sub_placeholders(self.url)),
                    ('license', self.license),
                    ('summary', self.pacified_text(section="Title")),
                    ('description', self.pacified_text(section="Description")),
                )),
            ),
        ))

        if self.license_file_location():
            d['about']['license_file'] = self.license_file_location()

        if self.needsX:
            # Anything that causes rgl to get imported needs X around
            if not self.extra:
                self.extra = OrderedDict()
            self.extra['container'] = OrderedDict([('extended-base', True)])

            if 'build' not in d['requirements']:
                d['requirements']['build'] = []
            d['requirements']['build'].append("{{ cdt('mesa-libgl-devel') }}  # [linux]")
            d['requirements']['build'].append("{{ cdt('mesa-dri-drivers') }}  # [linux]")
            d['requirements']['build'].append("{{ cdt('libselinux') }}  # [linux]")
            d['requirements']['build'].append("{{ cdt('libxdamage') }}  # [linux]")
            d['requirements']['build'].append("{{ cdt('libxxf86vm') }}  # [linux]")
            d['requirements']['build'].append("xorg-libxfixes  # [linux]")

            d['test']['commands'] = ['''LD_LIBRARY_PATH="${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64" $R -e "library('{{ name }}')"''']


        if self.extra:
            d['extra'] = self.extra

        if self._cb3_build_reqs:
            d['requirements']['build'] = []
        else:
            d['build']['noarch'] = 'generic'
        for k, v in self._cb3_build_reqs.items():
            d['requirements']['build'].append(k + '_' + "PLACEHOLDER")

        rendered = pyaml.dumps(d, width=1e6).decode('utf-8')

        # Add Suggests: and SystemRequirements:
        renderedsplit = rendered.split('\n')
        idx = renderedsplit.index('requirements:')
        if self.packages[self.package].get('SystemRequirements', None):
            renderedsplit.insert(idx, '# SystemRequirements: {}'.format(self.packages[self.package]['SystemRequirements']))
        if self.packages[self.package].get('Suggests', None):
            renderedsplit.insert(idx, '# Suggests: {}'.format(self.packages[self.package]['Suggests']))
        # Fix the core dependencies if this needsX
        if self.needsX:
            idx = len(renderedsplit) - 1 - renderedsplit[::-1].index('  build:')
            for idx2 in range(6):
                line = renderedsplit[idx+idx2]
                renderedsplit[idx+idx2] = line.strip("'").replace("''","'").replace(" '", " ")
        rendered = '\n'.join(renderedsplit) + '\n'

        rendered = (
            '{% set version = "' + self.version + '" %}\n' +
            '{% set name = "' + self.package + '" %}\n' +
            '{% set bioc = "' + self.bioc_version + '" %}\n\n' +
            rendered
        )

        for k, v in self._cb3_build_reqs.items():
            rendered = rendered.replace(k + '_' + "PLACEHOLDER", v)

        tmpdir = tempfile.mkdtemp()
        with open(os.path.join(tmpdir, 'meta.yaml'), 'w') as fout:
            fout.write(rendered)
        return fout.name


def write_recipe_recursive(proj, seen_dependencies, recipe_dir, config, force,
                           bioc_version, pkg_version, versioned, recursive):
    """
    Parameters
    ----------

    proj : BioCProjectPage object

    seen_dependencies : list
        Dependencies to ignore

    recipe_dir : str
        Path to recipe dir

    config : str
        Path to recipes config file

    force : bool
        If True, any recipes that already exist will be overwritten.
    """
    logger.debug('%s has dependencies: %s', proj.package, proj.dependencies)
    for conda_name, cran_or_bioc_name in proj.dependencies.items():

        # For now, this function is version-agnostic. so we strip out any
        # version info when checking if we've seen this dep before.
        conda_name_without_version = re.sub(r' >=.*$', '', conda_name)
        if conda_name.startswith('r-base'):
            continue

        if conda_name_without_version in seen_dependencies:
            logger.debug(
                "{} already created or in existing channels, skipping"
                .format(conda_name_without_version))
            continue

        seen_dependencies.update([conda_name_without_version])

        if conda_name_without_version.startswith('r-'):
            writer = cran_skeleton.write_recipe
        else:
            writer = write_recipe
        writer(
            package=cran_or_bioc_name,
            recipe_dir=recipe_dir,
            config=config,
            force=force,
            bioc_version=bioc_version,
            pkg_version=pkg_version,
            versioned=versioned,
            recursive=recursive,
            seen_dependencies=seen_dependencies,
        )


def write_recipe(package, recipe_dir, config, force=False, bioc_version=None,
                 pkg_version=None, versioned=False, recursive=False, seen_dependencies=None,
                 packages=None, skip_if_in_channels=None, needs_x=None):
    """
    Write the meta.yaml and build.sh files. If the package is detected to be
    a data package (bsed on the detected URL from Bioconductor), then also
    create a post-link.sh and pre-unlink.sh script that will download and
    install the package.

    Parameters
    ----------

    package : str
        Bioconductor package name (case-sensitive)

    recipe_dir : str

    config : str or dict

    force : bool
        If True, then recipes will get overwritten. If **recursive** is also
        True, *all* recipes created will get overwritten.

    bioc_version : str
        Version of Bioconductor to target

    pkg_version : str
        Force a particular package version

    versioned : bool
        If True, then make a subdirectory for this version

    recursive : bool
        If True, then also build any R or Bioconductor packages in the same
        recipe directory.

    seen_dependencies : set
        Dependencies to skip and will be updated with any packages built by
        this function. Used internally when ``recursive=True``.

    packages : dict
        A dictionary, as returned by fetchPackages(), of all packages in a
        given bioconductor release and their versions.

    skip_if_in_channels : list or None
        List of channels whose existing packages will be automatically added to
        **seen_dependencies**. Only has an effect if ``recursive=True``.

    needs_x : bool or None
        If None, we need to determine if this requires X and therefore additional
        build dependencies and test environment variables.
    """
    config = utils.load_config(config)
    proj = BioCProjectPage(package, bioc_version, pkg_version, packages=packages)
    logger.info('Making recipe for: {}'.format(package))

    if seen_dependencies is None:
        seen_dependencies = set()

    if not needs_x:
        needing_x = packagesNeedingX(proj.packages)
        needs_x = package.lower() in needing_x
    proj.needsX = needs_x

    if recursive:
        # get a list of existing packages in channels
        if skip_if_in_channels is not None:
            for name in set(utils.RepoData().get_package_data("name", channels=skip_if_in_channels)):
                if name.startswith(('r-', 'bioconductor-')):
                    seen_dependencies.add(name)

        write_recipe_recursive(proj, seen_dependencies, recipe_dir, config,
                               force, bioc_version, pkg_version, versioned,
                               recursive)

    logger.debug('%s==%s, BioC==%s', proj.package, proj.version, proj.bioc_version)
    logger.info('Using tarball from %s', proj.tarball_url)
    if versioned:
        recipe_dir = os.path.join(recipe_dir, 'bioconductor-' + proj.package.lower(), proj.version)
    else:
        recipe_dir = os.path.join(recipe_dir, 'bioconductor-' + proj.package.lower())
    if os.path.exists(recipe_dir) and not force:
        raise ValueError("{0} already exists, aborting".format(recipe_dir))
    else:
        if not os.path.exists(recipe_dir):
            logger.info('creating %s' % recipe_dir)
            os.makedirs(recipe_dir)

    # If the version number has not changed but something else in the recipe
    # *has* changed, then bump the version number.
    meta_file = os.path.join(recipe_dir, 'meta.yaml')
    if os.path.exists(meta_file):
        updated_meta = utils.load_first_metadata(proj.meta_yaml, finalize=False).meta
        current_meta = utils.load_first_metadata(meta_file, finalize=False).meta

        # pop off the version and build numbers so we can compare the rest of
        # the dicts
        updated_version = updated_meta['package']['version']
        current_version = current_meta['package']['version']

        # updated_build_number = updated_meta['build'].pop('number')
        current_build_number = current_meta['build'].pop('number', 0)

        if (
            (updated_version == current_version) and
            (updated_meta != current_meta)
        ):
            proj.build_number = int(current_build_number) + 1
        if 'extra' in current_meta:
            exclude = set(['final', 'copy_test_source_files'])
            proj.extra = {x: y for x, y in current_meta['extra'].items() if x not in exclude}

    with open(os.path.join(recipe_dir, 'meta.yaml'), 'w') as fout:
        fout.write(open(proj.meta_yaml).read())

    if not proj.is_data_package:
        with open(os.path.join(recipe_dir, 'build.sh'), 'w') as fout:
            if needs_x:
                fout.write(dedent(
                    '''\
                    #!/bin/bash
                    mv DESCRIPTION DESCRIPTION.old
                    grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
                    mkdir -p ~/.R
                    echo -e "CC=$CC
                    FC=$FC
                    CXX=$CXX
                    CXX98=$CXX
                    CXX11=$CXX
                    CXX14=$CXX" > ~/.R/Makevars
                    export LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64
                    $R CMD INSTALL --build .'''
                    )
                )
            else:
                fout.write(dedent(
                    '''\
                    #!/bin/bash
                    mv DESCRIPTION DESCRIPTION.old
                    grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
                    mkdir -p ~/.R
                    echo -e "CC=$CC
                    FC=$FC
                    CXX=$CXX
                    CXX98=$CXX
                    CXX11=$CXX
                    CXX14=$CXX" > ~/.R/Makevars
                    $R CMD INSTALL --build .'''
                    )
                )

    else:
        urls = [
            '"{0}"'.format(u) for u in [
                proj.bioconductor_tarball_url,
                bioarchive_url(proj.package, proj.version, proj.bioc_version),
                cargoport_url(proj.package, proj.version, proj.bioc_version),
                proj.cargoport_url
            ]
            if u is not None
        ]
        urls = '  ' + '\n  '.join(urls)
        post_link_template = dedent(
            '''\
            #!/bin/bash
            FN="{proj.tarball_basename}"
            URLS=(
            '''.format(proj=proj))

        post_link_template += urls
        post_link_template += dedent(
            '''
            )
            MD5="{proj.md5}"
            '''.format(proj=proj, urls=urls))
        post_link_template += dedent(
            """
            # Use a staging area in the conda dir rather than temp dirs, both to avoid
            # permission issues as well as to have things downloaded in a predictable
            # manner.
            STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
            mkdir -p $STAGING
            TARBALL=$STAGING/$FN

            SUCCESS=0
            for URL in ${URLS[@]}; do
              curl $URL > $TARBALL
              [[ $? == 0 ]] || continue

              # Platform-specific md5sum checks.
              if [[ $(uname -s) == "Linux" ]]; then
                if md5sum -c <<<"$MD5  $TARBALL"; then
                  SUCCESS=1
                  break
                fi
              else if [[ $(uname -s) == "Darwin" ]]; then
                if [[ $(md5 $TARBALL | cut -f4 -d " ") == "$MD5" ]]; then
                  SUCCESS=1
                  break
                fi
              fi
            fi
            done

            if [[ $SUCCESS != 1 ]]; then
              echo "ERROR: post-link.sh was unable to download any of the following URLs with the md5sum $MD5:"
              printf '%s\\n' "${URLS[@]}"
              exit 1
            fi

            # Install and clean up
            R CMD INSTALL --library=$PREFIX/lib/R/library $TARBALL
            rm $TARBALL
            rmdir $STAGING
            """)  # noqa: E501: line too long
        with open(os.path.join(recipe_dir, 'post-link.sh'), 'w') as fout:
            fout.write(dedent(post_link_template))
        pre_unlink_template = "R CMD REMOVE --library=$PREFIX/lib/R/library/ {0}\n".format(package)
        with open(os.path.join(recipe_dir, 'pre-unlink.sh'), 'w') as fout:
            fout.write(pre_unlink_template)

    logger.info('Wrote recipe in %s', recipe_dir)
