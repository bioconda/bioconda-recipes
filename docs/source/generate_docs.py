import os
import os.path as op
from collections import defaultdict
from jinja2 import Template
from jinja2.sandbox import SandboxedEnvironment
from bioconda_utils import utils
from sphinx.util import logging as sphinx_logging
from sphinx.util import status_iterator
from sphinx.util.template import SphinxRenderer
from sphinx.util.rst import escape as rst_escape
from sphinx.util.osutil import ensuredir
from sphinx.jinja2glue import BuiltinTemplateLoader
from distutils.version import LooseVersion

try:
    logger = sphinx_logging.getLogger(__name__)
except AttributeError:  # not running within sphinx
    import logging
    logger = logging.getLogger(__name__)

try:
    from conda_build.metadata import MetaData
except Exception:
    logging.exception("Failed to import MetaData")
    raise


BASE_DIR = op.dirname(op.abspath(__file__))
RECIPE_DIR = op.join(op.dirname(BASE_DIR), 'bioconda-recipes', 'recipes')
OUTPUT_DIR = op.join(BASE_DIR, 'recipes')


class RepoData(object):
    def __init__(self):
        logger.info('Loading packages...')
        repodata = defaultdict(lambda: defaultdict(list))
        for platform in ['linux', 'osx']:
            for pkg in utils.get_channel_packages(channel='bioconda',
                                                  platform=platform):
                name, version, _ = self.parse_pkgname(pkg)
                repodata[name][version].append(platform)
        self.repodata = repodata
        # e.g., repodata = {
        #   'package1': {
        #       '0.1': ['linux'],
        #       '0.2': ['linux', 'osx'],
        #   },
        # }

    def parse_pkgname(self, p):
        p = p.replace('.tar.bz2', '')
        toks = p.split('-')
        build_string = toks.pop()
        version = toks.pop()
        name = '-'.join(toks)
        return name, version, build_string

    def get_versions(self, p):
        return self.repodata[p]


class Renderer(object):
    def __init__(self, app):
        template_loader = BuiltinTemplateLoader()
        template_loader.init(app.builder)
        template_env = SandboxedEnvironment(loader=template_loader)
        template_env.filters['escape'] = lambda x: rst_escape(x) if x else x
        template_env.filters['underline'] = lambda x: x + '\n' + '=' * len(x)
        self.env = template_env
        self.templates = {}

    def render(self, template_name, context):
        try:
            template = self.templates[template_name]
        except KeyError:
            template = self.env.get_template(template_name)
            self.templates[template_name] = template

        return template.render(**context)

    def render_to_file(self, file_name, template_name, context):
        content = self.render(template_name, context)
        # skip if exists and unchanged:
        if os.path.exists(file_name):
            with open(file_name, encoding="utf-8") as f:
                if f.read() == content:
                    return False  # unchanged
        ensuredir(op.dirname(file_name))

        with open(file_name, "wb") as f:
            f.write(content.encode("utf-8"))
        return True


def generate_readme(folder, repodata, renderer):
    # Subfolders correspond to different versions
    versions = []
    for sf in os.listdir(op.join(RECIPE_DIR, folder)):
        if not op.isdir(op.join(RECIPE_DIR, folder, sf)):
            # Not a folder
            continue
        try:
            LooseVersion(sf)
        except ValueError:
            logger.error("'{}' does not look like a proper version!"
                         "".format(sf))
            continue
        versions.append(sf)

    # Read the meta.yaml file(s)
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
            return

    name = metadata.name()
    versions_in_channel = repodata.get_versions(name)

    # Format the README
    template_options = {
        'name': name,
        'about': metadata.get_section('about'),
        'extra': metadata.get_section('extra'),
        'versions': ', '.join(sorted(versions_in_channel.keys())),
        'license': metadata.get_section('about').get('license', ''),
        'gh_recipes': 'https://github.com/bioconda/bioconda-recipes/tree/master/recipes/',
        'recipe_path': op.dirname(op.relpath(metadata.meta_path, RECIPE_DIR)),
        'Package': '<a href="recipes/{0}/README.html">{0}</a>'.format(name)
    }

    renderer.render_to_file(
        op.join(OUTPUT_DIR, folder, 'README.rst'),
        'readme.rst_t',
        template_options)

    recipes = []
    for version, version_info in sorted(versions_in_channel.items()):
        t = template_options.copy()
        t.update({
            'Linux': '<i class="fa fa-linux"></i>' if 'linux' in version_info else '',
            'OSX': '<i class="fa fa-apple"></i>' if 'osx' in version_info else '',
            'Version': version
        })
        recipes.append(t)
    return recipes


def generate_recipes(app):
    """
    Go through every folder in the `bioconda-recipes/recipes` dir
    and generate a README.rst file.
    """
    renderer = Renderer(app)
    repodata = RepoData()
    recipes = []
    recipe_dirs = os.listdir(RECIPE_DIR)
    recipe_dirs = recipe_dirs[1:101]
    for folder in status_iterator(recipe_dirs, 'Generating package READMEs...',
                                  "purple", len(recipe_dirs), app.verbosity):
        recipes.extend(generate_readme(folder, repodata, renderer))

    updated = renderer.render_to_file("source/recipes.rst", "recipes.rst_t", {
        'recipes': recipes,
        # order of columns in the table; must be keys in template_options
        'keys': ['Package', 'Version', 'License', 'Linux', 'OSX']
    })
    if updated:
        logger.info("Updated source/recipes.rst")


def setup(app):
    app.connect('builder-inited', generate_recipes)
