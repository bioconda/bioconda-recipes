import os
import sys
import os.path as op
try:
    from conda_build.metadata import MetaData
except Exception as e:
    import traceback
    traceback.print_exc()
    raise e
from distutils.version import LooseVersion
#import matplotlib
#matplotlib.use("agg")
#import matplotlib.pyplot as plt
#from wordcloud import WordCloud


BASE_DIR = op.dirname(op.abspath(__file__))
RECIPE_DIR = op.join(op.dirname(BASE_DIR), 'recipes')
OUTPUT_DIR = op.join(BASE_DIR, 'recipes')

README_TEMPLATE = u"""\
.. _`{title}`:

{title}
{title_underline}

|downloads|
|docker|

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

With an activated Bioconda channel (see :ref:`setup`), install with::

   conda install {title}

and update with::

   conda update {title}

{notes}

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


def setup(*args):
    """
    Go through every folder in the `bioconda-recipes/recipes` dir
    and generate a README.rst file.
    """
    print('Generating package READMEs...')
    # TODO obtain information from repodata.json.
    summaries = []
    for folder in os.listdir(RECIPE_DIR):
        try:
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
                assert isinstance(notes, str), "extra->notes must be a single string"
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
            readme = README_TEMPLATE.format(**template_options)
            # Write to file
            try:
                os.makedirs(op.join(OUTPUT_DIR, folder))  # exist_ok=True on Python 3
            except OSError:
                pass
            output_file = op.join(OUTPUT_DIR, folder, 'README.rst')
            with open(output_file, 'wb') as ofh:
                ofh.write(readme.encode('utf-8'))
        except (Exception, BaseException) as e:
            print("Error generating docs for recipe {}:".format(folder), file=sys.stderr)
            raise e

    #wordcloud = WordCloud(max_font_size=40,
    #                      background_color='white',
    #                      stopwords=set(['package', 'tool'])).generate(" ".join(summaries))
    #plt.imshow(wordcloud)
    #plt.axis("off")
    #plt.savefig(op.join(BASE_DIR, 'wordcloud.png'), bbox_inches='tight')


if __name__ == '__main__':
    setup()
