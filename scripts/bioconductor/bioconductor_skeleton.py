#!/usr/bin/env python

import shutil
import tempfile
import configparser
from textwrap import dedent
import tarfile
import pyaml
import hashlib
import os
import re
import bs4
import urllib
from urllib import request
from urllib import parse
from urllib import error
from collections import OrderedDict
import logging
import requests
from colorlog import ColoredFormatter

logging.getLogger("requests").setLevel(logging.WARNING)

log_stream_handler = logging.StreamHandler()
log_stream_handler.setFormatter(ColoredFormatter(
        "%(asctime)s %(log_color)sBIOCONDA %(levelname)s%(reset)s %(message)s",
        datefmt="%H:%M:%S",
        reset=True,
        log_colors={
            'DEBUG': 'cyan',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red',
        }))
logger = logging.getLogger(__name__)



def setup_logger(loglevel):
    LEVEL = getattr(logging, loglevel.upper())
    l = logging.getLogger(__name__)
    l.propagate = False
    l.setLevel(getattr(logging, loglevel.upper()))
    l.addHandler(log_stream_handler)

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


# A list of packages, in recipe name format
GCC_PACKAGES = ['r-rcpp']

HERE = os.path.abspath(os.path.dirname(__file__))


def bioconductor_versions():
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
    return bioconductor_versions()[0]


def bioconductor_tarball_url(package, pkg_version, bioc_version):
    return  (
    'http://bioconductor.org/packages/{bioc_version}'
    '/bioc/src/contrib/{package}_{pkg_version}.tar.gz'.format(**locals())
    )


def bioconductor_data_url(package, pkg_version, bioc_version):
    return  (
    'http://bioconductor.org/packages/{bioc_version}'
    '/data/annotation/src/contrib/{package}_{pkg_version}.tar.gz'.format(**locals())
    )

def find_best_bioc_version(package, version):
    """
    Given a package version number, identifies which BioC version[s] it is
    in and returns the latest.

    Returns None if no valid package found.
    """
    found_version = None

    for bioc_version in bioconductor_versions():
        for func in (bioconductor_tarball_url, bioconductor_data_url):
            url = func(package, version, bioc_version)
            if requests.head(url).status_code == 200:
                logger.debug('success: %s', url)
                logger.info(
                    'A working URL for %s==%s was identified for Bioconductor version %s: %s',
                    package, version, bioc_version, url)
                found_version = bioc_version
                break
            else:
                logger.debug('missing: %s', url)
        if found_version is not None:
            break
    return found_version


class PageNotFoundError(Exception): pass


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
        self._md5 = None
        self._cached_tarball = None
        self._dependencies = None
        self.build_number = 0
        self.bioc_version = bioc_version
        self.pkg_version = pkg_version
        self._cargoport_url = None
        self._bioarchive_url = None
        self._tarball_url = None
        self._bioconductor_tarball_url = None


        # If no version specified, assume the latest
        if not self.bioc_version:
            self.bioc_version = latest_bioconductor_version()

        self.request = requests.get(
            os.path.join(base_url, self.bioc_version, 'bioc', 'html', package + '.html')
        )

        if not self.request:
            self.request = requests.get(
                os.path.join(base_url, self.bioc_version, 'data', 'annotation', 'html', package + '.html')
            )

        if not self.request:
            raise PageNotFoundError('Error {0.status_code} ({0.reason}) for page {0.url}'.format(self.request))

        # Since we provide the "short link" we will get redirected. Using
        # requests allows us to keep track of the final destination URL, which
        # we need for reconstructing the tarball URL.
        self.url = self.request.url

        # The table at the bottom of the page has the info we want. An earlier
        # draft of this script parsed the dependencies from the details table.
        # That's still an option if we need a double-check on the DESCRIPTION
        # fields.
        soup = bs4.BeautifulSoup(
            self.request.content,
            'html.parser')
        details_table = soup.find_all(attrs={'class': 'details'})[0]

        # However, it is helpful to get the version info from this table. That
        # way we can try getting the bioaRchive tarball and cache that.
        for td in details_table.findAll('td'):
            if td.getText() == 'Version':
                version = td.findNext().getText()
                break

        if self.pkg_version is not None and version != self.pkg_version:
            logger.warn(
                "Latest version of %s is %s, but using specified version %s",
                self.package, version, self.pkg_version
            )
            self.version = self.pkg_version

        else:
            self.version = version

        self.depends_on_gcc = False


        # Used later to determine whether or not to auto-identify the best BioC
        # version
        self._auto = bioc_version is None
        if self._auto:
            self.bioc_version = find_best_bioc_version(self.package, self.version)

    @property
    def bioaRchive_url(self):
        """
        Returns the bioaRchive URL if one exists for this version of this
        package, otherwise returns None.
        """
        if self._bioarchive_url is None:
            url = 'https://bioarchive.galaxyproject.org/{0.package}_{0.version}.tar.gz'.format(self)
            response = requests.head(url)
            if response.status_code == 200:
                return url

    @property
    def cargoport_url(self):
        """
        Returns the Galaxy cargo-port URL for this version of this package,
        whether it exists or not. If none exists, a warning is printed.
        """
        if not self._cargoport_url:
            url = (
                'https://depot.galaxyproject.org/software/{0.package}/{0.package}_'
                '{0.version}_src_all.tar.gz'.format(self)
            )
            response = requests.get(url)
            if response.status_code == 404:
                logger.warn(
                    'Cargo Port URL (%s) does not exist. This is expected if '
                    'this is a new package or an updated version. Cargo Port '
                    'will archive a working URL upon merging', url
                )
            else:
                raise PageNotFoundError("Unexpected error: {0.status_code} ({0.reason})".format(response))

            self._cargoport_url = url
        return self._cargoport_url

    @property
    def bioconductor_tarball_url(self):
        """
        Return the url to the tarball from the bioconductor site.
        """
        return bioconductor_tarball_url(self.package, self.version, self.bioc_version)


    @property
    def bioconductor_data_url(self):
        """
        Return the url to the tarball from the bioconductor site.
        """
        return bioconductor_data_url(self.package, self.version, self.bioc_version)


    @property
    def tarball_url(self):
        if not self._tarball_url:
            urls = [self.bioconductor_tarball_url, self.bioconductor_data_url, self.bioaRchive_url, self.cargoport_url]
            for url in urls:
                response = requests.head(url)
                if response and response.status_code == 200:
                    return url

            logger.error(
                'No working URL for %s==%s in Bioconductor %s. '
                'Tried the following:\n\t' + '\n\t'.join(urls),
                self.package, self.version, self.bioc_version
            )

            if self._auto:
                find_best_bioc_version(self.package, self.version)

            if self._tarball_url is None:
                raise ValueError("No working URLs found for this version in any bioconductor version")
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
        cache_dir = os.path.join(HERE, 'cached_bioconductor_tarballs')
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
            if response:
                fout.write(response.content)
            else:
                raise PageNotFoundError('Unexpected error {0.status_code} ({0.reason})'.format(response))
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
        # configparser take care of the details of parsing.
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
        try:
            return [i.strip() for i in self.description['imports'].replace(' ', '').split(',')]
        except KeyError:
            return []

    @property
    def depends(self):
        try:
            return [i.strip() for i in self.description['depends'].replace(' ', '').split(',')]
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
        if self._dependencies:
            return self._dependencies

        results = []

        # Some packages specify a minimum R version, which we'll need to keep
        # track of
        specific_r_version = False

        # Sometimes a version is specified only in the `depends` and not in the
        # `imports`. We keep the most specific version of each.
        version_specs = list(
            set(
                self._parse_dependencies(self.imports) +
                self._parse_dependencies(self.depends)
            )
        )

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
                BioCProjectPage(name)
                prefix = 'bioconductor-'
            except PageNotFoundError:
                prefix = 'r-'

            logger.info('{0:>12} dependency: name="{1}" version="{2}"'.format(
                {'r-': 'R', 'bioconductor-': 'BioConductor'}[prefix],
                name, version))

            # add padding to version string
            if version:
                version = " " + version

            if name.lower() == 'r':

                # Had some issues with CONDA_R finding the right version if "r"
                # had version restrictions. Since we're generally building
                # up-to-date packages, we can just use "r".

                # # "r >=2.5" rather than "r-r >=2.5"
                # specific_r_version = True
                # results.append(name.lower() + version)
                # results.append('r')
                pass
            else:
                results.append(prefix + name.lower() + version)

            if prefix + name.lower() in GCC_PACKAGES:
                self.depends_on_gcc = True

        # Add R itself
        results.append('r-base')
        self._dependencies = results
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
        string.Template so as to avoid conflicting with the conda jinja
        templating or the `$R` in the test commands, and replace the text once
        the yaml is written.
        """
        url = [
            u for u in
            [self.bioconductor_tarball_url, self.bioaRchive_url, self.cargoport_url]
            if u is not None
        ]

        DEPENDENCIES = sorted(self.dependencies)
        d = OrderedDict((
            (
                'package', OrderedDict((
                    ('name', 'bioconductor-' + self.package.lower()),
                    ('version', self.version),
                )),
            ),
            (
                'source', OrderedDict((
                    ('fn', self.tarball_basename),
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
                    ('build', DEPENDENCIES[:]),
                    ('run', DEPENDENCIES[:]),
                )),
            ),
            (
                'test', OrderedDict((
                    ('commands',
                     ['''$R -e "library('{package}')"'''.format(
                         package=self.package)]),
                )),
            ),
            (
                'about', OrderedDict((
                    ('home', self.url),
                    ('license', self.license),
                    ('summary', self.description['description']),
                )),
            ),
        ))
        if self.depends_on_gcc:
            d['requirements']['build'].append('GCC_PLACEHOLDER')
            d['requirements']['build'].append('LLVM_PLACEHOLDER')

        rendered = pyaml.dumps(d).decode('utf-8')
        rendered = rendered.replace('GCC_PLACEHOLDER', 'gcc  # [linux]')
        rendered = rendered.replace('LLVM_PLACEHOLDER', 'llvm  # [osx]')
        return rendered


def write_recipe(package, recipe_dir, force=False, bioc_version=None,
                 pkg_version=None, versioned=False):
    """
    Write the meta.yaml and build.sh files.
    """
    proj = BioCProjectPage(package, bioc_version, pkg_version)
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
        updated_meta = pyaml.yaml.load(proj.meta_yaml)
        current_meta = pyaml.yaml.load(open(meta_file))

        # pop off the version and build numbers so we can compare the rest of
        # the dicts
        updated_version = updated_meta['package'].pop('version')
        current_version = current_meta['package'].pop('version')
        updated_build_number = updated_meta['build'].pop('number')
        current_build_number = current_meta['build'].pop('number')

        if (
            (updated_version == current_version)
            and
            (updated_meta != current_meta)
        ):
            proj.build_number = int(current_build_number) + 1


    with open(os.path.join(recipe_dir, 'meta.yaml'), 'w') as fout:
        fout.write(proj.meta_yaml)

    with open(os.path.join(recipe_dir, 'build.sh'), 'w') as fout:
        fout.write(dedent(
            """
            #!/bin/bash
            mv DESCRIPTION DESCRIPTION.old
            grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
            $R CMD INSTALL --build .
            # """
            )
        )
    logger.info('Wrote recipe in %s', recipe_dir)


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('package', help='Bioconductor package name')
    ap.add_argument('--recipes', default='recipes',
                    help='Recipe will be created in RECIPES/<package>')
    ap.add_argument('--versioned', action='store_true',
                    help='''If specified, recipe will be created in
                    RECIPES/<package>/<version>''')
    ap.add_argument('--force', action='store_true',
                    help='Overwrite the contents of an existing recipe')
    ap.add_argument('--pkg-version',
                    help='Package version to use instead of the current one')
    ap.add_argument('--bioc-version',
                    help="""Version of Bioconductor to target. If not
                    specified, then automatically finds the latest version of
                    Bioconductor with the specified version in --pkg-version,
                    or if --pkg-version not specified, then finds the the
                    latest package version in the latest Bioconductor
                    version""")
    ap.add_argument('--loglevel', default='debug',
                    help='Log level')
    args = ap.parse_args()
    setup_logger(args.loglevel)
    write_recipe(args.package, args.recipes, args.force,
                 bioc_version=args.bioc_version, pkg_version=args.pkg_version,
                 versioned=args.versioned)
