#!/usr/bin/env python

from textwrap import dedent
import yaml
import hashlib
import os
import re
import bs4
from urllib import request
from urllib import parse
from collections import OrderedDict

def ordereddict_constructor(loader, node):
    try:
        omap = loader.construct_yaml_omap(node)
        return OrderedDict(*omap)
    except yaml.constructor.ConstructorError:
        return loader.construct_yaml_seq(node)

def represent_ordereddict(dumper, data):
    # From https://bitbucket.org/xi/pyyaml/issues/13/loading-and-then-dumping-an-omap-is-broken
    values = []
    node = yaml.SequenceNode(u'tag:yaml.org,2002:seq', values, flow_style=False)
    if dumper.alias_key is not None:
        dumper.represented_objects[dumper.alias_key] = node
    for key, value in data.items():
        key_item = dumper.represent_data(key)
        value_item = dumper.represent_data(value)
        node_item = yaml.MappingNode(u'tag:yaml.org,2002:map', [(key_item, value_item)],
                                     flow_style=False)
        values.append(node_item)
    return node

yaml.add_constructor(u'tag:yaml.org,2002:seq', ordereddict_constructor)
yaml.add_representer(OrderedDict, represent_ordereddict)


class BioCProjectPage(object):
    def __init__(self, package, base_url='http://bioconductor.org/packages/release/bioc/html'):
        """
        Represents a single Bioconductor package page and provides access to scraped data.

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

    @property
    def tarball(self):
        """
        Return the url to the tarball indicated in the "Package Source" section.
        """
        r = re.compile('{0}.*\.tar.gz'.format(self.package))
        def f(href):
            return href and r.search(href)
        results = self.soup.find_all(href=f)
        assert len(results) == 1, "Found {0} tags with '.tar.gz' in href".format(len(results))
        s = list(results[0].stripped_strings)
        assert len(s) == 1
        return os.path.join(parse.urljoin(self.url, '../src/contrib'), s[0])

    @property
    def tarball_filename(self):
        return os.path.basename(self.tarball)

    @property
    def version(self):
        return str(self.details_table.findChild(text='Version').findNext().string)

    @property
    def license(self):
        return str(self.details_table.findChild(text='License').findNext().string)

    @property
    def imports(self):
        return self.details_table.findChild(text='Imports').findNext().findChildren()


    @property
    def dependencies(self):
        def _versioned_dependencies(children):
            results = []
            for c in children:
                if c.name == 'a':
                    pkg = c.string
                else:
                    continue
                if c.next_sibling and c.next_sibling.name is None:
                    version = c.next_sibling.string.replace(' ', '').replace(',', '')
                    if version:
                        version = version.replace('(', ' ').replace(')', '')
                else:
                    version = ""
                if c.get('class') == ['cran_package']:
                    prefix = 'r-'
                else:
                    prefix = 'bioconductor-'
                results.append(prefix + pkg.lower() + version + ' # ' + pkg)
            return results
        return list(set(_versioned_dependencies(self.imports) + _versioned_dependencies(self.depends)))


    @property
    def depends(self):
        return self.details_table.findChild(text='Depends').findNext()

    @property
    def cleaned_package(self):
        return 'bioconductor-' + self.package.lower()

    @property
    def md5(self):
        if self._md5 is None:
            self._md5 = hashlib.md5(request.urlopen(self.tarball).read()).hexdigest()
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
                    ('fn', self.tarball_filename),
                    ('url', self.tarball),
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
                    ('build', ['r'] + sorted(self.dependencies)),
                    ('run', ['r'] + sorted(self.dependencies)),
                )),
            ),
            (
                'test', OrderedDict((
                    ('commands', """$R -e "library('{package}')""".format(package=self.package)),
                )),
            ),
            (
                'about', OrderedDict((
                    ('home', self.url),
                    ('license', self.license),
                    ('summary', self.summary),
                )),
            ),
        ))
        return yaml.dump(d, default_flow_style=False)



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

            # R refuses to build packages that mark themselves as Priority: Recommended
            # mv DESCRIPTION DESCRIPTION.old
            # grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
            #
            # $R CMD INSTALL --build .
            #
            # # Add more build steps here, if they are necessary.
            #
            # # See
            # # http://docs.continuum.io/conda/build.html
            # # for a list of environment variables that are set during the build process.
            # """
            )
        )


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('package', help='Bioconductor package name')
    ap.add_argument('--recipe-dir', default='recipes',
                    help='Recipe will be created in <recipe-dir>/<package>')
    ap.add_argument('--force', action='store_true', help='Overwrite the contents of an existing recipe')
    args = ap.parse_args()
    write_recipe(args.package, args.recipe_dir, args.force)
