"""Bioconda-Utils sphinx extension

This module builds the documentation for our recipes
"""

import os
import os.path as op
from typing import Any, Dict, List, Tuple, Optional

from jinja2.sandbox import SandboxedEnvironment

from sphinx import addnodes
from docutils import nodes
from docutils.parsers import rst
from docutils.statemachine import StringList
from sphinx.domains import Domain, ObjType, Index
from sphinx.directives import ObjectDescription
from sphinx.environment import BuildEnvironment
from sphinx.roles import XRefRole
from sphinx.util import logging as sphinx_logging
from sphinx.util import status_iterator
from sphinx.util.docfields import Field, GroupedField
from sphinx.util.nodes import make_refnode
from sphinx.util.parallel import ParallelTasks, parallel_available, make_chunks
from sphinx.util.rst import escape as rst_escape
from sphinx.util.osutil import ensuredir
from sphinx.util.docutils import SphinxDirective
from sphinx.jinja2glue import BuiltinTemplateLoader

from conda.exports import VersionOrder

from bioconda_utils.utils import RepoData, load_config
from bioconda_utils.recipe import Recipe, RecipeError

# Aquire a logger
try:
    logger = sphinx_logging.getLogger(__name__)  # pylint: disable=invalid-name
except AttributeError:  # not running within sphinx
    import logging
    logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


BASE_DIR = op.dirname(op.abspath(__file__))
RECIPE_DIR = op.join(op.dirname(BASE_DIR), 'bioconda-recipes', 'recipes')
OUTPUT_DIR = op.join(BASE_DIR, 'recipes')
RECIPE_BASE_URL = 'https://github.com/bioconda/bioconda-recipes/tree/master/recipes/'
CONDA_FORGE_FORMAT = 'https://github.com/conda-forge/{}-feedstock'


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


def rst_escape_filter(text):
    """Jinja2 filter escaping RST symbols in text

    >>> rst_excape_filter("running `cmd.sh`")
    "running \`cmd.sh\`"
    """
    if text:
        return rst_escape(text)
    return text


def prefixes_filter(text, split):
    path = []
    for part in text.split(split):
        path.append(part)
        yield {'path': split.join(path), 'part': part}


def rst_link_filter(text, url):
    if url:
        return "`{} <{}>`_".format(text, url)
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
        template_env.filters['rst_escape'] = rst_escape_filter
        template_env.filters['underline'] = underline_filter
        template_env.filters['as_extlink'] = as_extlink_filter
        template_env.filters['prefixes'] = prefixes_filter
        template_env.filters['rst_link'] = rst_link_filter
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


class RequirementsField(GroupedField):
    """Field Type for ``.. conda:package::`` for specifying dependencies

    This does two things different than `GroupedField`:

    - No `--` inserted between argument and value
    - Entry added to domain data ``backrefs`` so that we can
      use the requirements to collect required-by data later.
    """
    def make_field(self, types, domain, items, env=None):
        fieldname = nodes.field_name('', self.label)
        listnode = self.list_type()
        for fieldarg, content in items:
            par = nodes.paragraph()
            par.extend(self.make_xrefs(self.rolename, domain, fieldarg,
                                       addnodes.literal_strong, env=env))
            if content and content[0].astext():
                par += nodes.Text(' ')
                par += content
            listnode += nodes.list_item('', par)

            source = env.ref_context['conda:package']
            backrefs = env.domains['conda'].data['backrefs'].setdefault(fieldarg, set())
            backrefs.add((env.docname, source))

        fieldbody = nodes.field_body('', listnode)
        fieldbody.set_class('field-list-wrapped')
        return nodes.field('', fieldname, fieldbody)


class RequiredByField(Field):
    """Field Type for directive ``.. conda:package::`` for showing required-by

    This just creates the field name and field body with a `pending_xref` in the
    body that will later be filled with the reverse dependencies by
    `resolve_required_by_xrefs`
    """
    def make_field(self, types, domain, item, env=None):
        fieldname = nodes.field_name('', self.label)
        backref = addnodes.pending_xref(
            '',
            refdomain="conda",
            reftype='requiredby', refexplicit=False,
            reftarget=env.ref_context['conda:package'],
            refdoc=env.docname
        )
        backref += nodes.inline('', '')
        fieldbody = nodes.field_body('', backref)
        return nodes.field('', fieldname, fieldbody)


def resolve_required_by_xrefs(app, env, node, contnode):
    """Now that all recipes and packages have been parsed, we are called here
    for each `pending_xref` node that sphinx has not been able to resolve.

    We handle specifically the `requiredby` reftype created by the
    `RequiredByField` fieldtype allowed in ``conda:package::`
    directives, where we replace the `pendinf_ref` node with a bullet
    list of reference nodes pointing to the package pages that
    "depended" on the package.
    """
    if node['reftype'] == 'requiredby' and node['refdomain'] == 'conda':
        target = node['reftarget']
        docname = node['refdoc']
        backrefs = env.domains['conda'].data['backrefs'].get(target, set())
        listnode = nodes.bullet_list()
        for back_docname, back_target in backrefs:
            par = nodes.paragraph()
            name_node = addnodes.literal_strong(back_target, back_target,
                                      classes=['xref', 'backref'])
            refnode = make_refnode(app.builder, docname,
                                   back_docname, back_target, name_node)
            refnode.set_class('conda-package')
            par += refnode
            listnode += nodes.list_item('', par)
        return listnode


class CondaObjectDescription(ObjectDescription):
    """Base class for `ObjectDescription`s in the `CondaDomain`"""
    typename = "[UNKNOWN]"

    option_spec = {
        'arch': rst.directives.unchanged,
        'badges': rst.directives.unchanged,
        'replaces_section_title': rst.directives.flag
    }

    def handle_signature(self, sig: str, signode: addnodes.desc) -> str:
        """Transform signature into RST nodes"""
        signode += addnodes.desc_annotation(self.typename, self.typename + " ")
        signode += addnodes.desc_name(sig, sig)

        if 'badges' in self.options:
            badges = addnodes.desc_annotation()
            badges['classes'] += ['badges']
            content = StringList([self.options['badges']])
            self.state.nested_parse(content, 0, badges)
            signode += badges


        if 'replaces_section_title' in self.options:
            section = self.state.parent
            if isinstance(section, nodes.section):
                title = section[-1]
                if isinstance(title, nodes.title):
                    section.remove(title)
                else:
                    signode += self.state.document.reporter.warning(
                        "%s:%s:: must follow section directly to replace section title"
                        % (self.domain, self.objtype), line = self.lineno
                    )
            else:
                signode += self.state.document.reporter.warning(
                    "%s:%s:: must be in section to replace section title"
                    % (self.domain, self.objtype), line = self.lineno
                )

        return sig

    def add_target_and_index(self, name: str, sig: str,
                             signodes: addnodes.desc) -> None:
        """Add to index and to domain data"""
        target_name = "-".join((self.objtype, name))
        if target_name not in self.state.document.ids:
            signodes['names'].append(target_name)
            signodes['ids'].append(target_name)
            signodes['first'] = (not self.names)
            self.state.document.note_explicit_target(signodes)
            objects = self.env.domaindata[self.domain]['objects']
            key = (self.objtype, name)
            if key in objects:
                if hasattr(self.env, 'warn'):
                    self.env.warn(
                        self.env.docname,
                        "Duplicate entry {} {} at {} (other in {})".format(
                            self.objtype, name, self.lineno,
                            self.env.doc2path(objects[key][0])))
            objects[key] = (self.env.docname, target_name)

        index_text = self.get_index_text(name)
        if index_text:
            self.indexnode['entries'].append(('single', index_text, target_name, '', None))

    def get_index_text(self, name: str) -> str:
        """This yields the text with which the object is entered into the index."""
        return "{} ({})".format(name, self.objtype)

    def before_content(self):
        """We register ourselves in the `ref_context` so that a later
        call to :depends:`packagename` knows within which package
        the dependency was added"""
        self.env.ref_context['conda:'+self.typename] = self.names[-1]


class CondaRecipe(CondaObjectDescription):
    """Directive ``.. conda:recipe::`` describing a Recipe
    """
    typename = "recipe"


class CondaPackage(CondaObjectDescription):
    """Directive ``.. conda:package::`` describing a Package

    This directive takes two specialized field types, ``requirements``
    and ``depends``:

    ```
    .. conda:package:: mypkg1

       :depends mypkg2: 2.0
       :depends mypkg3:
       :requirements:
    ```

    `:depends pkgname: [version]`
       Adds a dependency to the package.

    `:requirements:`
       Lists packages which referenced this package via `:depends pkgname:`

    """
    typename = "package"
    doc_field_types = [
        RequiredByField('requirements', names=('requirements',),
                        label=u'Required\u00a0By', has_arg=False),
        RequirementsField('depends', names=('depends', 'dependencies', 'deps'),
                          label="Depends", rolename='depends'),
    ]


class RecipeIndex(Index):
    name = "recipe_index"
    localname = "Recipe Index"
    shortname = "Recipes"

    def generate(self, docnames: Optional[List[str]] = None):
        content = {}

        objects = sorted(self.domain.data['objects'].items())
        for (typ, name), (docname, labelid) in objects:
            if docnames and docname not in docnames:
                continue
            entries = content.setdefault(name[0].lower(), [])
            subtype = 0 # 1 has subentries, 2 is subentry
            entries.append((
                name, subtype, docname, labelid, 'extra', 'qualifier', 'description'
            ))

        collapse = True
        return sorted(content.items()), collapse


class CondaDomain(Domain):
    """Domain for Conda Packages"""
    name = "conda"
    label = "Conda"

    object_types = {
        # ObjType(name, *roles, **attrs)
        'recipe': ObjType('recipe', 'recipe'),
        'package': ObjType('package', 'package'),
    }
    directives = {
        'recipe': CondaRecipe,
        'package': CondaPackage,
    }
    roles = {
        'recipe': XRefRole(),
        'package': XRefRole(),
    }
    initial_data = {
        'objects': {},  #: (type, name) -> docname, labelid
        'backrefs': {}  #: package_name -> docname, package_name
    }
    indices = [
        RecipeIndex
    ]

    def clear_doc(self, docname: str):
        # docs copied from Domain class
        """Remove traces of a document in the domain-specific inventories."""
        if 'objects' not in self.data:
            return
        to_remove = [
            key for (key, (stored_docname, _)) in self.data['objects'].items()
            if docname == stored_docname
        ]
        for key  in to_remove:
            del self.data['objects'][key]

    def resolve_xref(self, env: BuildEnvironment, fromdocname: str,
                     builder, typ, target, node, contnode):
        # docs copied from Domain class
        """Resolve the pending_xref *node* with the given *typ* and *target*.

        This method should return a new node, to replace the xref node,
        containing the *contnode* which is the markup content of the
        cross-reference.

        If no resolution can be found, None can be returned; the xref node will
        then given to the :event:`missing-reference` event, and if that yields no
        resolution, replaced by *contnode*.

        The method can also raise :exc:`sphinx.environment.NoUri` to suppress
        the :event:`missing-reference` event being emitted.
        """
        if typ == 'depends':
            # 'depends' role is handled just like a 'package' here (resolves the same)
            typ = 'package'
        elif typ == 'requiredby':
            # 'requiredby' role type is deferred to missing_references stage
            return None

        for objtype in self.objtypes_for_role(typ):
            if (objtype, target) in self.data['objects']:
                node = make_refnode(
                    builder, fromdocname,
                    self.data['objects'][objtype, target][0],
                    self.data['objects'][objtype, target][1],
                    contnode, target + ' ' + objtype)
                node.set_class('conda-package')
                return node

            if objtype == "package":
                # Avoid going through the entire repodata CF - we cache a set of the
                # packages available via conda-forge here.
                if not hasattr(env, 'conda_forge_packages'):
                    pkgs = set(RepoData().get_package_data('name', channels='conda-forge'))
                    env.conda_forge_packages = pkgs
                else:
                    pkgs = env.conda_forge_packages

                if target in pkgs:
                    uri = CONDA_FORGE_FORMAT.format(target)
                    node = nodes.reference('', '', internal=False,
                                           refuri=uri, classes=['conda-forge'])
                    node += contnode
                    return node

        return None  # triggers missing-reference

    def get_objects(self):
        # docs copied from Domain class
        """Return an iterable of "object descriptions", which are tuples with
        five items:

        * `name`     -- fully qualified name
        * `dispname` -- name to display when searching/linking
        * `type`     -- object type, a key in ``self.object_types``
        * `docname`  -- the document where it is to be found
        * `anchor`   -- the anchor name for the object
        * `priority` -- how "important" the object is (determines placement
          in search results)

          - 1: default priority (placed before full-text matches)
          - 0: object is important (placed before default-priority objects)
          - 2: object is unimportant (placed after full-text matches)
          - -1: object should not show up in search at all
        """
        for (typ, name), (docname, ref) in self.data['objects'].items():
            dispname = "Recipe '{}'".format(name)
            yield name, dispname, typ, docname, ref, 1

    def merge_domaindata(self, docnames: List[str], otherdata: Dict) -> None:
        """Merge in data regarding *docnames* from a different domaindata
        inventory (coming from a subprocess in parallel builds).
        """
        for (typ, name), (docname, ref) in otherdata['objects'].items():
            if docname in docnames:
                self.data['objects'][typ, name] = (docname, ref)
        # broken?
        #for key, data in otherdata['backrefs'].items():
        #    if docname in docnames:
        #        xdata = self.data['backrefs'].setdefault(key, set())
        #        xdata |= data


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
    meta_relpath = meta_fname[len(RECIPE_DIR)+1:]

    # Read the meta.yaml file(s)
    try:
        recipe = Recipe.from_file(RECIPE_DIR, meta_fname)
    except RecipeError as e:
        logger.error("Unable to process %s: %s", meta_fname, e)
        return []

    # Format the README
    packages = []
    for package in sorted(list(set(recipe.package_names))):
        versions_in_channel = set(repodata.get_package_data(['version', 'build_number'],
                                                            channels='bioconda', name=package))
        sorted_versions = sorted(versions_in_channel,
                                 key=lambda x: (VersionOrder(x[0]), x[1]),
                                 reverse=True)

        if sorted_versions:
            depends = [
                depstring.split(' ', 1) if ' ' in depstring else (depstring, '')
                for depstring in
                repodata.get_package_data('depends', name=package,
                                          version=sorted_versions[0][0],
                                          build_number=sorted_versions[0][1],
                )[0]
            ]
        else:
            depends = []

        packages.append({
            'name': package,
            'versions': ['-'.join(str(w) for w in v) for v in sorted_versions],
            'depends' : depends,
        })

    template_options = {
        'name': recipe.name,
        'about': recipe.get('about'),
        'extra': recipe.get('extra'),
        'recipe': recipe,
        'gh_recipes': RECIPE_BASE_URL,
        'packages': packages,
    }

    renderer.render_to_file(output_file, 'readme.rst_t', template_options)
    return []

def generate_recipes(app):
    """
    Go through every folder in the `bioconda-recipes/recipes` dir,
    have a README.rst file generated and generate a recipes.rst from
    the collected data.
    """
    renderer = Renderer(app)
    load_config(os.path.join(os.path.dirname(RECIPE_DIR), "config.yml"))
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


def add_ribbon(app, pagename, templatename, context, doctree):
    if templatename != 'page.html':
        return
    if pagename.startswith('_autosummary') or pagename.startswith('_modules'):
        _, _, path = pagename.partition('/')
        path = path.replace('.', '/') + '.py'
        repo = 'bioconda-utils'
    elif pagename.startswith('recipes/') and pagename.endswith('/README'):
        repo = 'bioconda-recipes'
        path = pagename[:-len('README')] + 'meta.yaml'
    else:
        repo = 'bioconda-utils'
        path = 'docs/source/' + os.path.relpath(doctree.get('source'), app.builder.srcdir)

    context['git_ribbon_url'] = (f'https://github.com/bioconda/{repo}/'
                                 f'edit/master/{path}')
    context['git_ribbon_message'] = "Edit me on GitHub"



def setup(app):
    """Set up sphinx extension"""
    app.add_domain(CondaDomain)
    app.add_directive('autorecipes', AutoRecipesDirective)
    app.connect('builder-inited', generate_recipes)
    app.connect('missing-reference', resolve_required_by_xrefs)
    app.connect('html-page-context', add_ribbon)
    return {
        'version': "0.0.0",
        'parallel_read_safe': True,
        'parallel_write_safe': True
    }
