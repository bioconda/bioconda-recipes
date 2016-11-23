import os
import os.path as op
from jinja2 import Template
from bioconda_utils import utils

try:
    from conda_build.metadata import MetaData
except Exception as e:
    import traceback
    traceback.print_exc()
    raise e
from distutils.version import LooseVersion


BASE_DIR = op.dirname(op.abspath(__file__))
RECIPE_DIR = op.join(op.dirname(BASE_DIR), 'bioconda-recipes', 'recipes')
OUTPUT_DIR = op.join(BASE_DIR, 'recipes')

# jinja2 template for the DataTable of recipes
RECIPES_TEMPLATE = u"""\
.. _recipes:

Recipes
=======

.. toctree::
   :hidden:
   :maxdepth: 1
   :glob:

   recipes/*/*

.. raw:: html

    <table id="recipestable" class="display" cellspacing="0" width="100%">
    <thead>
        <tr>
        {% for key in keys %}
        <th>{{ key }}</th>
        {% endfor %}
        </tr>
    </thead>
    <tbody>
    {% for r in recipes %}
    <tr>
        {% for k in keys %}
        <td>{{ r[k] }}</td>
        {% endfor %}
    </tr>
    {% endfor %}
    </tbody>
    </table>
"""


README_TEMPLATE = u"""\
.. _`{title}`:

{title}
{title_underline}

|downloads|

{summary}

======== ===========
Home     {home}
Versions {versions}
License  {license}
Recipe   {recipe}
======== ===========

Installation
------------

.. highlight: bash

With an activated Bioconda channel (see :ref:`set-up-channels`), install with::

   conda install {title}

and update with::

   conda update {title}

{notes}

|docker|

A Docker container is available at https://quay.io/repository/biocontainers/{title}.

Link to this page
-----------------

Render an |badge| badge with the following Markdown::

   [![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](http://bioconda.github.io/recipes/{title}/README.html)

.. |badge| image:: https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square
           :target: http://bioconda.github.io/recipes/{title}/README.html
.. |downloads| image:: https://anaconda.org/bioconda/{title}/badges/downloads.svg
               :target: https://anaconda.org/bioconda/{title}
.. |docker| image:: https://quay.io/repository/biocontainers/{title}/status
                :target: https://quay.io/repository/biocontainers/{title}


"""

def parse_pkgname(p):
    p = p.replace('.tar.bz2', '')
    toks = p.split('-')
    build_string = toks.pop()
    version = toks.pop()
    name = '-'.join(toks)
    return dict(name=name, version=version, build_string=build_string)


def setup(*args):
    """
    Go through every folder in the `bioconda-recipes/recipes` dir
    and generate a README.rst file.
    """
    print('Generating package READMEs...')
    # TODO obtain information from repodata.json.
    summaries = []
    recipes = []

    linux_packages = [parse_pkgname(i)['name'] for i in utils.get_channel_packages(channel='bioconda', platform='linux')]
    osx_packages = [parse_pkgname(i)['name'] for i in utils.get_channel_packages(channel='bioconda', platform='osx')]

    for folder in os.listdir(RECIPE_DIR):
        # Subfolders correspond to different versions
        versions = []
        for sf in os.listdir(op.join(RECIPE_DIR, folder)):
            if not op.isdir(op.join(RECIPE_DIR, folder, sf)):
                # Not a folder
                continue
            try:
                LooseVersion(sf)
            except ValueError:
                print("'{}' does not look like a proper version!".format(sf))
                continue
            versions.append(sf)
        #versions.sort(key=LooseVersion, reverse=True)
        # Read the meta.yaml file
        recipe = op.join(RECIPE_DIR, folder, "meta.yaml")
        if op.exists(recipe):
            metadata = MetaData(recipe)
            if metadata.version() not in versions:
                versions.insert(0, metadata.version())
        else:
            if versions:
                recipe = op.join(RECIPE_DIR, folder, versions[0], "meta.yaml")
                metadata = MetaData(recipe)
            else:
                # ignore non-recipe folders
                continue

        # Format the README
        notes = metadata.get_section('extra').get('notes', '')
        if notes:
            notes = 'Notes\n-----\n\n' + notes
        summary = metadata.get_section('about').get('summary', '')
        summaries.append(summary)
        template_options = {
            'title': metadata.name(),
            'title_underline': '=' * len(metadata.name()),
            'summary': summary,
            'home': metadata.get_section('about').get('home', ''),
            'versions': ', '.join(versions),
            'license': metadata.get_section('about').get('license', ''),
            'recipe': ('https://github.com/bioconda/bioconda-recipes/tree/master/recipes/' +
                op.dirname(op.relpath(metadata.meta_path, RECIPE_DIR))),
            'notes': notes
        }

        # add additional keys for the recipes datatable.
        template_options['Package'] = template_options['title']
        template_options['Links'] = (
            '<a href="recipes/{2}/README.html">install</a>'
            '| <a href="{0}">recipe</a>'
            '| <a href="{1}">homepage</a>'
            .format(
                template_options['recipe'],
                template_options['home'],
                template_options['title'])
        )
        template_options['Versions'] = template_options['versions']

        availability = {
            (True, True): 'Linux & OSX',
            (True, False): 'Linux only',
            (False, True): 'OSX only',
            (False, False): 'unavailable',
        }
        template_options['Availability'] = availability[
            (template_options['title'] in linux_packages,
             template_options['title'] in osx_packages)
        ]

        recipes.append(template_options)

        readme = README_TEMPLATE.format(**template_options)
        # Write to file
        try:
            os.makedirs(op.join(OUTPUT_DIR, folder))  # exist_ok=True on Python 3
        except OSError:
            pass
        output_file = op.join(OUTPUT_DIR, folder, 'README.rst')

        # avoid re-writing the same contents, which invalidates the
        # sphinx-build cache
        if os.path.exists(output_file):
            if open(output_file, encoding='utf-8').read() == readme:
                continue

        with open(output_file, 'wb') as ofh:
            ofh.write(readme.encode('utf-8'))

    # render the recipes datatable page
    t = Template(RECIPES_TEMPLATE)
    recipes_contents = t.render(
        recipes=recipes,

        # order of columns in the table; must be keys in template_options
        keys=['Package', 'Versions', 'Links', 'Availability']
    )
    recipes_rst = 'source/recipes.rst'
    if not (
        os.path.exists(recipes_rst)
        and (open(recipes_rst).read() == recipes_contents)
    ):
        with open(recipes_rst, 'w') as fout:
            fout.write(recipes_contents)

if __name__ == '__main__':
    setup()
