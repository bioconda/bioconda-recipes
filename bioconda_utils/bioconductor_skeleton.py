#!/usr/bin/env python

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

from . import utils
from . import cran_skeleton

logging.getLogger("requests").setLevel(logging.WARNING)

logger = utils.setup_logger(__name__)

base_url = 'http://bioconductor.org/packages/'

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
    regex = re.compile('^/packages/(?P<version>\d+\.\d+)/$')
    url = 'https://www.bioconductor.org/about/release-announcements/#release-versions'
    response = requests.get(url)
    soup = bs4.BeautifulSoup(response.content, 'html.parser')
    versions = []
    for a in soup.find_all('a', href=True):
        ref = a.attrs['href']
        m = regex.search(ref)
        if m:
            versions.append(m.group('version'))
    versions = sorted(versions, key=float, reverse=True)
    return versions


def latest_bioconductor_version():
    """
    Latest Bioconductor version scraped from the Bioconductor site.
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


class BioCProjectPage(object):
    def __init__(self, package, bioc_version=None, pkg_version=None):
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
        self._sha256 = None
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

        # If no version specified, assume the latest
        if not self.bioc_version:
            if not self._pkg_version:
                self.bioc_version = latest_bioconductor_version()
            else:
                self.bioc_version = find_best_bioc_version(self.package, self._pkg_version)
        htmls = {
            'regular_package': os.path.join(
                base_url, self.bioc_version, 'bioc', 'html', package
                + '.html'),
            'annotation_package': os.path.join(
                base_url, self.bioc_version, 'data', 'annotation', 'html',
                package + '.html'),
            'experiment_package': os.path.join(
                base_url, self.bioc_version, 'data', 'experiment', 'html',
                package + '.html'),
        }
        tried = []
        for label, url in htmls.items():
            request = requests.get(url)
            tried.append(url)
            if request:
                break

        if not request:
            raise PageNotFoundError(
                'Could not find HTML page for {0.package}. Tried: '
                '{1}'.format(self, ', '.join(tried)))

        # Since we provide the "short link" we will get redirected. Using
        # requests allows us to keep track of the final destination URL,
        # which we need for reconstructing the tarball URL.
        self.url = request.url
            
        # If no version has been provided, the following code finds the latest
        # version by finding and scraping the HTML page for the package's
        # "Details" table.

        if self._pkg_version is not None:
            self.version = self._pkg_version

        else:
            htmls = {
                'regular_package': os.path.join(
                    base_url, self.bioc_version, 'bioc', 'html',
                    package + '.html'),
                'annotation_package': os.path.join(
                    base_url, self.bioc_version, 'data', 'annotation', 'html',
                    package + '.html'),
                'experiment_package': os.path.join(
                    base_url, self.bioc_version, 'data', 'experiment', 'html',
                    package + '.html'),
            }
            tried = []
            for label, url in htmls.items():
                request = requests.get(url)
                tried.append(url)
                if request:
                    break

            if not request:
                raise PageNotFoundError(
                    'Could not find HTML page for {0.package}. Tried: '
                    '{1}'.format(self, ', '.join(tried)))

            # Since we provide the "short link" we will get redirected. Using
            # requests allows us to keep track of the final destination URL,
            # which we need for reconstructing the tarball URL.
            self.url = request.url

            # The table at the bottom of the page has the info we want. An
            # earlier draft of this script parsed the dependencies from the
            # details table.  That's still an option if we need a double-check
            # on the DESCRIPTION fields. For now, we're grabbing the version
            # information from the table.
            soup = bs4.BeautifulSoup(request.content, 'html.parser')
            details_table = soup.find_all(attrs={'class': 'details'})[0]

            parsed_html_version = None
            for td in details_table.findAll('td'):
                if td.getText() == 'Version':
                    parsed_html_version = td.findNext().getText()
                    break

            if parsed_html_version is None:
                raise ValueError(
                    "Could not scrape latest version information from "
                    "{0}".format(self.url))

            self.version = parsed_html_version

        self.depends_on_gcc = False

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
        response = requests.get(url)
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
        url = bioconductor_tarball_url(self.package, self.version, self.bioc_version)
        response = requests.head(url)
        if response.status_code == 200:
            return url

    @property
    def bioconductor_annotation_data_url(self):
        """
        Return the url to the tarball from the bioconductor site.
        """
        url = bioconductor_annotation_data_url(self.package, self.version, self.bioc_version)
        response = requests.head(url)
        if response.status_code == 200:
            self.is_data_package = True
            return url

    @property
    def bioconductor_experiment_data_url(self):
        """
        Return the url to the tarball from the bioconductor site.
        """
        url = bioconductor_experiment_data_url(self.package, self.version, self.bioc_version)
        response = requests.head(url)
        if response.status_code == 200:
            self.is_data_package = True
            return url

    @property
    def tarball_url(self):
        if not self._tarball_url:
            urls = [self.bioconductor_tarball_url,
                    self.bioconductor_annotation_data_url,
                    self.bioconductor_experiment_data_url,
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
        Downloads the tarball to the `cached_bioconductor_tarballs` dir if one
        hasn't already been downloaded for this package.

        This is because we need the whole tarball to get the DESCRIPTION file
        and to generate an md5 hash, so we might as well save it somewhere.
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
    def description(self):
        """
        Extract the DESCRIPTION file from the tarball and parse it.
        """
        t = tarfile.open(self.cached_tarball)
        d = t.extractfile(os.path.join(self.package, 'DESCRIPTION')).read()
        self._contents = d
        c = configparser.ConfigParser(strict=False)

        # On-spec config files need a "section", but the DESCRIPTION file
        # doesn't have one. So we just add a fake section, and let the
        # configparser module take care of the details of parsing.
        c.read_string('[top]\n' + d.decode('UTF-8'))
        e = c['top']

        # Glue together newlines
        for k in e.keys():
            e[k] = e[k].replace('\n', ' ')

        return dict(e)

    @property
    def license(self):
        return self.description['license']

    @property
    def imports(self):
        """
        List of "imports" from the DESCRIPTION file
        """
        try:
            return [i.strip() for i in self.description['imports'].replace(' ', '').split(',')]
        except KeyError:
            return []

    @property
    def depends(self):
        """
        List of "depends" from the DESCRIPTION file
        """
        try:
            return [i.strip() for i in self.description['depends'].replace(' ', '').split(',')]
        except KeyError:
            return []

    @property
    def linkingto(self):
        """
        List of "linkingto" from the DESCRIPTION file
        """
        try:
            return [i.strip() for i in self.description['linkingto'].replace(' ', '').split(',')]
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
            try:
                BioCProjectPage(name, bioc_version=self.bioc_version)
                prefix = 'bioconductor-'
            except PageNotFoundError:
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

        if (
            (self.description.get('needscompilation', 'no') == 'yes') or
            (self.description.get('linkingto', None) is not None)
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
        if self._md5 is None:
            self._md5 = hashlib.md5(
                open(self.cached_tarball, 'rb').read()).hexdigest()
        return self._md5

    @property
    def sha256(self):
        """
        Calculate the sha256 hash of the tarball so it can be filled into the
        meta.yaml.
        """
        if self._sha256 is None:
            self._sha256 = hashlib.sha256(
                open(self.cached_tarball, 'rb').read()).hexdigest()
        return self._sha256

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
        for `# [linux]` and `# [osx]`.

        We do this with a unique placeholder (not a jinja or $-based
        string.Template) so as to avoid conflicting with the conda jinja
        templating or the `$R` in the test commands, and replace the text once
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
                self.bioconductor_annotation_data_url,
                self.bioconductor_experiment_data_url,

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
            additional_run_deps.append('wget')

        d = OrderedDict((
            (
                'package', OrderedDict((
                    ('name', 'bioconductor-{{ name|lower }}'),
                    ('version', '{{ version }}'),
                )),
            ),
            (
                'source', OrderedDict((
                    ('fn', '{{ name }}_{{ version }}.tar.gz'),
                    ('url', url),
                    ('sha256', self.sha256),
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
                    ('summary', self.description['description']),
                )),
            ),
        ))

        if self._cb3_build_reqs:
            d['requirements']['build'] = []
        for k, v in self._cb3_build_reqs.items():
            d['requirements']['build'].append(k + '_' + "PLACEHOLDER")

        rendered = pyaml.dumps(d, width=1e6).decode('utf-8')
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
                 skip_if_in_channels=None):
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
        If True, then recipes will get overwritten. If `recursive` is also
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
        this function. Used internally when `recursive=True`.

    skip_if_in_channels : list or None
        List of channels whose existing packages will be automatically added to
        `seen_dependencies`. Only has an effect if `recursive=True`.
    """
    config = utils.load_config(config)
    proj = BioCProjectPage(package, bioc_version, pkg_version)
    logger.info('Making recipe for: {}'.format(package))

    if seen_dependencies is None:
        seen_dependencies = set()

    if recursive:
        # get a list of existing packages in channels
        if skip_if_in_channels is not None:
            for channel in skip_if_in_channels:
                logger.info('Downloading channel repodata for %s', channel)
                for repodata in utils.get_channel_repodata(channel):
                    for pkg in repodata['packages'].values():
                        name = pkg['name']
                        if name.startswith(('r-', 'bioconductor-')):
                            seen_dependencies.update([name])

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
        updated_meta = utils.load_first_metadata(proj.meta_yaml).meta
        current_meta = utils.load_first_metadata(meta_file).meta

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

    with open(os.path.join(recipe_dir, 'meta.yaml'), 'w') as fout:
        fout.write(open(proj.meta_yaml).read())

    if not proj.is_data_package:
        with open(os.path.join(recipe_dir, 'build.sh'), 'w') as fout:
            fout.write(dedent(
                '''\
                #!/bin/bash
                mv DESCRIPTION DESCRIPTION.old
                grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
                $R CMD INSTALL --build .'''
                )
            )

    else:
        urls = [
            '"{0}"'.format(u) for u in [
                proj.bioconductor_tarball_url,
                proj.bioconductor_annotation_data_url,
                proj.bioconductor_experiment_data_url,
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
              wget -O- -q $URL > $TARBALL
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
