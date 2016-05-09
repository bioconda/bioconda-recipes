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

logging.basicConfig(level=logging.INFO, format='[bioconductor_skeleton.py %(asctime)s]: %(message)s')
logger = logging.getLogger()
logging.getLogger("requests").setLevel(logging.WARNING)

base_url = 'http://bioconductor.org/packages/'

# Packages that might be specified in the DESCRIPTION of a package as
# dependencies, but since they're built-in we don't need to specify them in
# the meta.yaml.
#
# Note: this list is from:
#
#   conda create -n rtest -c r r
#   R -e "rownames(installed.packages())"
BASE_R_PACKAGES = ["base", "boot", "class", "cluster", "codetools", "compiler",
                   "datasets", "foreign", "graphics", "grDevices", "grid",
                   "KernSmooth", "lattice", "MASS", "Matrix", "methods",
                   "mgcv", "nlme", "nnet", "parallel", "rpart", "spatial",
                   "splines", "stats", "stats4", "survival", "tcltk", "tools",
                   "utils"]

HERE = os.path.abspath(os.path.dirname(__file__))

class PageNotFoundError(Exception): pass

class BioCProjectPage(object):
    def __init__(self, package):
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
        self.request = requests.get(os.path.join(base_url, package))
        if not self.request:
            raise PageNotFoundError('Error {0.status_code} ({0.reason})'.format(self.request))

        # Since we provide the "short link" we will get redirected. Using
        # requests allows us to keep track of the final destination URL, which
        # we need for reconstructing the tarball URL.
        self.url = self.request.url


        # The table at the bottom of the page has the info we want. An earlier
        # draft of this script parsed the dependencies from the details table.
        # That's still an option if we need a double-check on the DESCRIPTION
        # fields.
        self.soup = bs4.BeautifulSoup(
            self.request.content,
            'html.parser')
        self.details_table = self.soup.find_all(attrs={'class': 'details'})[0]

        # However, it is helpful to get the version info from this table. That
        # way we can try getting the bioaRchive tarball and cache that.
        for td in self.details_table.findAll('td'):
            if td.getText() == 'Version':
                version = td.findNext().getText()
                break
        self.version = version

    @property
    def bioaRchive_url(self):
        """
        Returns the bioaRchive URL if one exists for this version of this
        package, otherwise returns None.

        Note that to get the package version, we're still getting the
        bioconductor tarball to extract the DESCRIPTION file.
        """
        url = 'https://bioarchive.galaxyproject.org/{0.package}_{0.version}.tar.gz'.format(self)
        response = requests.get(url)
        if response:
            return url
        elif response.status_code == 404:
            return
        else:
            raise PageNotFoundError("Unexpected error: {0.status_code} ({0.reason})".format(response))


    @property
    def bioconductor_tarball_url(self):
        """
        Return the url to the tarball from the bioconductor site.
        """
        r = re.compile('{0}.*\.tar.gz'.format(self.package))

        def f(href):
            return href and r.search(href)

        results = self.soup.find_all(href=f)
        assert len(results) == 1, (
            "Found {0} tags with '.tar.gz' in href".format(len(results)))
        s = list(results[0].stripped_strings)
        assert len(s) == 1

        # build the actual URL based on the identified package name and the
        # relative URL from the source. Here we're just hard-coding
        # '../src/contrib' based on the structure of the bioconductor site.
        return os.path.join(parse.urljoin(self.url, '../src/contrib'), s[0])

    @property
    def tarball_url(self):
        url = self.bioaRchive_url
        if url:
            return url
        return self.bioconductor_tarball_url

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
        c = configparser.ConfigParser()

        # On-spec config files need a "section", but the DESCRIPTION file
        # doesn't have one. So we just add a fake section, and let the
        # configparser take care of the details of parsing.
        c.read_string('[top]\n' + d.decode('UTF-8'))
        e = c['top']

        # Glue together newlines
        for k in e.keys():
            e[k] = e[k].replace('\n', ' ')

        return dict(e)

    #@property
    #def version(self):
    #    return self.description['version']

    @property
    def license(self):
        return self.description['license']

    @property
    def imports(self):
        try:
            return self.description['imports'].split(', ')
        except KeyError:
            return []

    @property
    def depends(self):
        try:
            return self.description['depends'].split(', ')
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
                # "r >=2.5" rather than "r-r >=2.5"
                specific_r_version = True
                results.append(name.lower() + version)
            else:
                results.append(prefix + name.lower() + version)

        # Add R itself if no specific version was specified
        if not specific_r_version:
            results.append('r')
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
        this script have the same consistent format. Otherwise we're the whims
        of Python dict sorting.

        We use pyaml (rather than yaml) because it has better handling of
        OrderedDicts.
        """
        url = self.bioaRchive_url
        if not url:
            url = self.tarball_url

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
        return pyaml.dumps(d).decode('utf-8')


def write_recipe(package, recipe_dir, force=False):
    """
    Write the meta.yaml and build.sh files.
    """
    proj = BioCProjectPage(package)
    recipe_dir = os.path.join(recipe_dir, 'bioconductor-' + proj.package.lower())
    if os.path.exists(recipe_dir) and not force:
        raise ValueError("{0} already exists, aborting".format(recipe_dir))
    else:
        if not os.path.exists(recipe_dir):
            print('creating %s' % recipe_dir)
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

            # R refuses to build packages that mark themselves as
            # "Priority: Recommended"
            mv DESCRIPTION DESCRIPTION.old
            grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
            #
            $R CMD INSTALL --build .
            #
            # # Add more build steps here, if they are necessary.
            #
            # See
            # http://docs.continuum.io/conda/build.html
            # for a list of environment variables that are set during the build
            # process.
            # """
            )
        )


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('package', help='Bioconductor package name')
    ap.add_argument('--recipes', default='recipes',
                    help='Recipe will be created in <recipe-dir>/<package>')
    ap.add_argument('--force', action='store_true',
                    help='Overwrite the contents of an existing recipe')
    args = ap.parse_args()
    write_recipe(args.package, args.recipes, args.force)
