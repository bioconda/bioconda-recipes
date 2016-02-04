#!/usr/bin/env python3
import os
import os.path as op
from conda_build.metadata import MetaData
from distutils.version import LooseVersion

BASE_DIR = op.dirname(op.abspath(__file__))
RECIPE_DIR = op.join(op.dirname(BASE_DIR), 'recipes')
OUTPUT_DIR = op.join(BASE_DIR, 'recipes')

README_TEMPLATE = """\
.. _`{title}`:

{title}
{title_underline}

Summary
-------

{summary}


Home
----

{home}


Versions
--------

{versions}


License
-------

{license}


Meta
----

.. literalinclude:: {meta_file}
   :language: yaml

"""


def setup(*args):
    """
    Go through every folder in the `bioconda-recipes/recipes` dir
    and generate a README.rst file.
    """
    print('Generating package READMEs...')
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
        versions.sort(key=LooseVersion, reverse=True)
        # Read the meta.yaml file
        try:
            metadata = MetaData(op.join(RECIPE_DIR, folder))
            if metadata.version() not in versions:
                versions.insert(0, metadata.version())
        except SystemExit:
            if versions:
                metadata = MetaData(op.join(RECIPE_DIR, folder, versions[0]))
            else:
                raise
        # Format the README
        template_options = {
            'title': metadata.name(),
            'title_underline': '=' * len(metadata.name()),
            'summary': metadata.get_section('about').get('summary', ''),
            'home': metadata.get_section('about').get('home', ''),
            'versions': (
                '\n'.join(['- {}'.format(f) for f in versions])),
            'license': metadata.get_section('about').get('license', ''),
            'meta_file': (
                op.relpath(metadata.meta_path, op.join(OUTPUT_DIR, folder)))
        }
        readme = README_TEMPLATE.format(**template_options)
        # Write to file
        os.makedirs(op.join(OUTPUT_DIR, folder), exist_ok=True)
        output_file = op.join(OUTPUT_DIR, folder, 'README.rst')
        with open(output_file, 'wt') as ofh:
            ofh.write(readme)


if __name__ == '__main__':
    setup()
