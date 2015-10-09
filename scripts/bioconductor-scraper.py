#!/usr/bin/env python

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
from collections import OrderedDict

base_url = 'http://bioconductor.org/packages/release/bioc/html'


class BioCProjectPage(object):
    def __init__(self, package):
        """
        Represents a single Bioconductor package page and provides access to
        scraped data.

        >>> x = BioCProjectPage('DESeq2')
        >>> x.tarball
        'http://bioconductor.org/packages/release/bioc/src/contrib/DESeq2_1.8.2.tar.gz'
        """
        self.base_url = base_url
        self.package = package
        self.url = os.path.join(base_url, package + '.html')
        self.soup = bs4.BeautifulSoup(
            request.urlopen(self.url),
            'html.parser')

        self.details_table = self.soup.find_all(attrs={'class': 'details'})[0]
        self._md5 = None
        self.sanitized_package = 'bioconductor-' + package.lower()
        self._cached_tarball = None

    @property
    def tarball_url(self):
        """
        Return the url to the tarball indicated in the "Package Source"
        section of the project's page.
        """
        r = re.compile('{0}.*\.tar.gz'.format(self.package))

        def f(href):
            return href and r.search(href)

        results = self.soup.find_all(href=f)
        assert len(results) == 1, (
            "Found {0} tags with '.tar.gz' in href".format(len(results)))
        s = list(results[0].stripped_strings)
        assert len(s) == 1
        return os.path.join(parse.urljoin(self.url, '../src/contrib'), s[0])

    @property
    def tarball_basename(self):
        return os.path.basename(self.tarball_url)

    @property
    def cached_tarball(self):
        if self._cached_tarball:
            return self._cached_tarball
        fn = tempfile.NamedTemporaryFile(delete=False).name
        with open(fn, 'wb') as fout:
            fout.write(request.urlopen(self.tarball_url).read())
        self._cached_tarball = fn
        return fn

    @property
    def description(self):
        t = tarfile.open(self.cached_tarball)
        d = t.extractfile(os.path.join(self.package, 'DESCRIPTION')).read()
        self._contents = d
        c = configparser.ConfigParser()
        c.read_string('[top]\n' + d.decode('UTF-8'))
        e = c['top']
        for k in e.keys():
            e[k] = e[k].replace('\n', ' ')
        return dict(e)

    @property
    def version(self):
        return str(
            self.details_table.findChild(text='Version').findNext().string)

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
        results = []
        for item in items:
            toks = item.split(' (')
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
        results = []
        specific_r_version = False
        for name, version in list(
            set(
                self._parse_dependencies(self.imports) +
                self._parse_dependencies(self.depends)
            )
        ):
            # Try finding the dependency on the bioconductor site; if it can't
            # be found then we assume it's in CRAN.
            try:
                BioCProjectPage(name)
                prefix = 'bioconductor-'
            except urllib.error.HTTPError:
                prefix = 'r-'
            if name in ['methods', 'utils']:
                continue
            # add padding
            if version:
                version = " " + version
            if name.lower() == 'r':
                specific_r_version = True
                results.append(name.lower() + version)
            else:
                results.append(prefix + name.lower() + version)

        if not specific_r_version:
            results.append('r')
        return results

    @property
    def cleaned_package(self):
        return 'bioconductor-' + self.package.lower()

    @property
    def md5(self):
        if self._md5 is None:
            self._md5 = hashlib.md5(
                open(self.cached_tarball, 'rb').read()).hexdigest()
        return self._md5

    @property
    def summary(self):
        return str(self.soup.h2.string)

    @property
    def meta_yaml(self):
        d = OrderedDict((
            (
                'package', OrderedDict((
                    ('name', self.cleaned_package),
                    ('version', self.version),
                )),
            ),
            (
                'source', OrderedDict((
                    ('fn', self.tarball_basename),
                    ('url', self.tarball_url),
                    ('md5', self.md5),
                )),
            ),
            (
                'build', OrderedDict((
                    ('number', 0),
                    ('rpaths', ['lib/R/lib/', 'lib/']),
                )),
            ),
            (
                'requirements', OrderedDict((
                    ('build', sorted(self.dependencies)),
                    ('run', sorted(self.dependencies)),
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
    proj = BioCProjectPage(package)
    recipe_dir = os.path.join(recipe_dir, proj.sanitized_package)
    if os.path.exists(recipe_dir) and not force:
        raise ValueError("{0} already exists, aborting".format(recipe_dir))
    else:
        if not os.path.exists(recipe_dir):
            print('creating %s' % recipe_dir)
            os.makedirs(recipe_dir)

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
    ap.add_argument('--recipe-dir', default='recipes',
                    help='Recipe will be created in <recipe-dir>/<package>')
    ap.add_argument('--force', action='store_true',
                    help='Overwrite the contents of an existing recipe')
    args = ap.parse_args()
    write_recipe(args.package, args.recipe_dir, args.force)
