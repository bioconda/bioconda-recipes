"""Bioconda-Utils sphinx extension

This module builds the documentation for our recipes
"""

import os
import os.path as op
from typing import Any, Dict, List

from jinja2.sandbox import SandboxedEnvironment

from sphinx.util import logging as sphinx_logging
from sphinx.util import status_iterator
from sphinx.util.parallel import ParallelTasks, parallel_available, make_chunks
from sphinx.util.rst import escape as rst_escape
from sphinx.util.osutil import ensuredir
from sphinx.jinja2glue import BuiltinTemplateLoader

from conda.exports import VersionOrder

from bioconda_utils.utils import RepoData, load_config

# Aquire a logger
try:
    logger = sphinx_logging.getLogger(__name__)  # pylint: disable=invalid-name
except AttributeError:  # not running within sphinx
    import logging
    logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

try:
    from conda_build.metadata import MetaData
    from conda_build.exceptions import UnableToParse
except Exception:
    logging.exception("Failed to import MetaData")
    raise


BASE_DIR = op.dirname(op.abspath(__file__))
RECIPE_DIR = op.join(op.dirname(BASE_DIR), 'bioconda-recipes', 'recipes')
OUTPUT_DIR = op.join(BASE_DIR, 'recipes')


def as_extlink_filter(text):
    """Jinja2 filter converting identifier (list) to extlink format

    Args:
      text: may be string or list of strings

    >>> as_extlink_filter("biotools:abyss")
    "biotools: :biotool:`abyss`"

    >>> as_extlink_filter(["biotools:abyss", "doi:123"])
    "biotools: :biotool:`abyss`, doi: :doi:`123`"
    """
    def fmt(text):
        assert isinstance(text, str), "identifier has to be a string"
        text = text.split(":", 1)
        assert len(text) == 2, "identifier needs at least one colon"
        return "{0}: :{0}:`{1}`".format(*text)

    assert isinstance(text, list), "identifiers have to be given as list"

    return list(map(fmt, text))


def underline_filter(text):
    """Jinja2 filter adding =-underline to row of text

    >>> underline_filter("headline")
    "headline\n========"
    """
    return text + "\n" + "=" * len(text)


def escape_filter(text):
    """Jinja2 filter escaping RST symbols in text

    >>> excape_filter("running `cmd.sh`")
    "running \`cmd.sh\`"
    """
    if text:
        return rst_escape(text)
    return text


class Renderer:
    """Jinja2 template renderer

    - Loads and caches templates from paths configured in conf.py
    - Makes additional jinja filters available:
      - underline -- turn text into a RSt level 1 headline
      - escape -- escape RST special characters
      - as_extlink -- convert (list of) identifiers to extlink references
    """
    def __init__(self, app):
        template_loader = BuiltinTemplateLoader()
        template_loader.init(app.builder)
        template_env = SandboxedEnvironment(loader=template_loader)
        template_env.filters['escape'] = escape_filter
        template_env.filters['underline'] = underline_filter
        template_env.filters['as_extlink'] = as_extlink_filter
        self.env = template_env
        self.templates: Dict[str, Any] = {}

    def render(self, template_name, context):
        """Render a template file to string

        Args:
          template_name: Name of template file
          context: dictionary to pass to jinja
        """
        try:
            template = self.templates[template_name]
        except KeyError:
            template = self.env.get_template(template_name)
            self.templates[template_name] = template

        return template.render(**context)

    def render_to_file(self, file_name, template_name, context):
        """Render a template file to a file

        Ensures that target directories exist and only writes
        the file if the content has changed.

        Args:
          file_name: Target file name
          template_name: Name of template file
          context: dictionary to pass to jinja

        Returns:
          True if a file was written
        """
        content = self.render(template_name, context)

        # skip if exists and unchanged:
        if os.path.exists(file_name):
            with open(file_name, encoding="utf-8") as filedes:
                if filedes.read() == content:
                    return False  # unchanged

        ensuredir(op.dirname(file_name))
        with open(file_name, "w", encoding="utf-8") as filedes:
            filedes.write(content)
        return True


def generate_readme(folder, repodata, renderer):
    """Generates README.rst for the recipe in folder

    Args:
      folder: Toplevel folder name in recipes directory
      repodata: RepoData object
      renderer: Renderer object

    Returns:
      List of template_options for each concurrent version for
      which meta.yaml files exist in the recipe folder and its
      subfolders
    """
    output_file = op.join(OUTPUT_DIR, folder, 'README.rst')

    # Select meta yaml
    meta_fname = op.join(RECIPE_DIR, folder, 'meta.yaml')
    if not op.exists(meta_fname):
        for item in os.listdir(op.join(RECIPE_DIR, folder)):
            dname = op.join(RECIPE_DIR, folder, item)
            if op.isdir(dname):
                fname = op.join(dname, 'meta.yaml')
                if op.exists(fname):
                    meta_fname = fname
                    break
        else:
            logger.error("No 'meta.yaml' found in %s", folder)
            return []
    meta_relpath = meta_fname[len(RECIPE_DIR):]

    # Read the meta.yaml file(s)
    try:
        metadata = MetaData(meta_fname)
    except UnableToParse:
        logger.error("Failed to parse recipe %s", meta_fname)
        return []

    name = metadata.name()
    versions_in_channel = repodata.get_versions(name)
    sorted_versions = sorted(versions_in_channel.keys(), key=VersionOrder, reverse=True)

    # Format the README
    template_options = {
        'name': name,
        'about': (metadata.get_section('about') or {}),
        'extra': (metadata.get_section('extra') or {}),
        'versions': sorted_versions,
        'gh_recipes': 'https://github.com/bioconda/bioconda-recipes/tree/master/recipes/',
        'recipe_path': meta_relpath,
        'Package': '<a href="recipes/{0}/README.html">{0}</a>'.format(folder)
    }

    renderer.render_to_file(output_file, 'readme.rst_t', template_options)

    versions = []
    for version in sorted_versions:
        version_info = versions_in_channel[version]
        version_tpl = template_options.copy()
        version_tpl.update({
            'Linux': '<i class="fa fa-linux"></i>' if 'linux' in version_info else '',
            'OSX': '<i class="fa fa-apple"></i>' if 'osx' in version_info else '',
            'Version': version
        })
        versions.append(version_tpl)
    return versions


def generate_recipes(app):
    """
    Go through every folder in the `bioconda-recipes/recipes` dir,
    have a README.rst file generated and generate a recipes.rst from
    the collected data.
    """
    renderer = Renderer(app)
    load_config(os.path.join(os.path.dirname(__file__), "config.yaml"))
    repodata = RepoData()
    repodata.set_cache(op.join(app.env.doctreedir, 'RepoDataCache.csv'))
    # force loading repodata to avoid duplicate loads from threads
    repodata.df  # pylint: disable=pointless-statement
    recipes: List[Dict[str, Any]] = []
    recipe_dirs = os.listdir(RECIPE_DIR)

    if parallel_available and len(recipe_dirs) > 5:
        nproc = app.parallel
    else:
        nproc = 1

    if nproc == 1:
        for folder in status_iterator(
                recipe_dirs,
                'Generating package READMEs...',
                "purple", len(recipe_dirs), app.verbosity):
            if not op.isdir(op.join(RECIPE_DIR, folder)):
                logger.error("Item '%s' in recipes folder is not a folder",
                             folder)
                continue
            recipes.extend(generate_readme(folder, repodata, renderer))
    else:
        tasks = ParallelTasks(nproc)
        chunks = make_chunks(recipe_dirs, nproc)

        def process_chunk(chunk):
            _recipes: List[Dict[str, Any]] = []
            for folder in chunk:
                if not op.isdir(op.join(RECIPE_DIR, folder)):
                    logger.error("Item '%s' in recipes folder is not a folder",
                                 folder)
                    continue
                _recipes.extend(generate_readme(folder, repodata, renderer))
            return _recipes

        def merge_chunk(_chunk, res):
            recipes.extend(res)

        for chunk in status_iterator(
                chunks,
                'Generating package READMEs with {} threads...'.format(nproc),
                "purple", len(chunks), app.verbosity):
            tasks.add_task(process_chunk, chunk, merge_chunk)
        logger.info("waiting for workers...")
        tasks.join()

    updated = renderer.render_to_file("source/recipes.rst", "recipes.rst_t", {
        'recipes': recipes,
        # order of columns in the table; must be keys in template_options
        'keys': ['Package', 'Version', 'License', 'Linux', 'OSX']
    })
    if updated:
        logger.info("Updated source/recipes.rst")


def setup(app):
    """Set up sphinx extension"""
    app.connect('builder-inited', generate_recipes)
    return {
        'version': "0.0.0",
        'parallel_read_safe': True,
        'parallel_write_safe': True
    }
