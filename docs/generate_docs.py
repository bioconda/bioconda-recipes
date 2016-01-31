# -*- coding: utf-8 -*-
import os
import os.path as op
import yaml
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
            meta_file = op.join(RECIPE_DIR, folder, 'meta.yaml')
            with open(meta_file, 'rb') as ifh:
                meta = yaml.load(ifh)
            if meta['package']['version'] not in versions:
                versions.insert(0, meta['package']['version'])
        except FileNotFoundError:
            if versions:
                meta_file = (
                    op.join(RECIPE_DIR, folder, versions[0], 'meta.yaml'))
                with open(meta_file, 'rb') as ifh:
                    meta = yaml.load(ifh)
            else:
                raise
        except yaml.scanner.ScannerError:
            print(
                "The following recipe is improperly formatted: {}. "
                "Skipping..."
                .format(meta_file)
            )
            continue
        # Format the README
        template_options = {
            'title': (
                meta['package']['name']),
            'title_underline': (
                '=' * len(meta['package']['name'])),
            'summary': (
                meta['about'].get('summary') if
                meta['about'].get('summary') else
                ''),
            'home': (
                meta['about'].get('home') if
                meta['about'].get('home') else
                ''),
            'versions': (
                '\n'.join(['- {}'.format(f) for f in versions])),
            'license': (
                meta['about'].get('license')
                if meta['about'].get('license')
                else ''),
            'meta_file': op.relpath(meta_file, op.join(OUTPUT_DIR, folder))
        }
        readme = README_TEMPLATE.format(**template_options)
        # Write to file
        os.makedirs(op.join(OUTPUT_DIR, folder), exist_ok=True)
        output_file = op.join(OUTPUT_DIR, folder, 'README.rst')
        with open(output_file, 'wb') as ofh:
            ofh.write(readme.encode('utf-8'))


if __name__ == '__main__':
    setup()
