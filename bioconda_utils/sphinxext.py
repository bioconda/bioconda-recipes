"""Bioconda-Utils sphinx extension

This module builds the documentation for our recipes

To build the documentation locally, use e.g::

    make -C docs/ BIOCONDA_FILTER_RECIPES=10 SPHINXOPTS="-E" html

.. rubric:: Environment Variables

.. envvar:: BIOCONDA_FILTER_RECIPES

   Use this environment variable to reduce the number of recipes for
   which documentation pages are built. If set to an integer
   (including 0), the first *n* recipes are included. Otherwise, the
   contents are considered a regular expression recipes must match to
   be included.



"""

import os
import os.path as op
import re
import inspect
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
from bioconda_utils.githandler import BiocondaRepo
from bioconda_utils.lint import get_checks

# Aquire a logger
try:
    logger = sphinx_logging.getLogger(__name__)  # pylint: disable=invalid-name
except AttributeError:  # not running within sphinx
    import logging
    logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


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
    "headline\\n========"

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
    """Jinja2 filter"""
    path = []
    for part in text.split(split):
        path.append(part)
        yield {'path': split.join(path), 'part': part}


def rst_link_filter(text, url):
    """Jinja2 filter creating RST link

    >>> rst_link_filter("bla", "https://somewhere")
    "`bla <https://somewhere>`_"
    """
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
    def __init__(self, app, extra_context):
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
        self.extra_context = extra_context

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
        content = self.render(template_name, {**self.extra_context, **context})

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

    This does two things different than ``GroupedField``:

    - No ``--`` inserted between argument and value
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

    This just creates the field name and field body with a ``pending_xref`` in the
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
    for each ``pending_xref`` node that sphinx has not been able to resolve.

    We handle specifically the ``requiredby`` reftype created by the
    `RequiredByField` fieldtype allowed in ``conda:package::``
    directives, where we replace the ``pending_ref`` node with a bullet
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
    """Base class for ``ObjectDescription`` types in the `CondaDomain`"""
    typename = "[UNKNOWN]"

    option_spec = {
        'arch': rst.directives.unchanged,
        'badges': rst.directives.unchanged,
        'replaces_section_title': rst.directives.flag,
        'noindex': rst.directives.flag,
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
        """We register ourselves in the ``ref_context`` so that a later
        call to ``:depends:`packagename``` knows within which package
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

    .. code:: rst

        .. conda:package:: mypkg1

           :depends mypkg2: 2.0
           :depends mypkg3:
           :requirements:

    ``:depends pkgname: [version]``
       Adds a dependency to the package.

    ``:requirements:``
       Lists packages which referenced this package via ``:depends pkgname:``

    """
    typename = "package"
    doc_field_types = [
        RequiredByField('requirements', names=('requirements',),
                        label=u'Required\u00a0By', has_arg=False),
        RequirementsField('depends', names=('depends', 'dependencies', 'deps'),
                          label="Depends", rolename='depends'),
    ]


class PackageIndex(Index):
    """Index of Packages"""

    name = "package_index"
    localname = "Package Index"
    shortname = "Packages"

    def generate(self, docnames: Optional[List[str]] = None):
        """build index"""
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
        'package': ObjType('package', 'package', 'depends'),
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
        PackageIndex
    ]

    def clear_doc(self, docname: str):
        """Remove traces of a document in the domain-specific inventories."""
        if 'objects' not in self.data:
            return
        to_remove = [
            key for (key, (stored_docname, _)) in self.data['objects'].items()
            if docname == stored_docname
        ]
        for key  in to_remove:
            del self.data['objects'][key]

    def resolve_any_xref(self, env: BuildEnvironment, fromdocname: str,
                         builder, target, node, contnode):
        """Resolve references from "any" role."""
        res = self.resolve_xref(env, fromdocname, builder, 'package', target, node, contnode)
        if res:
            return [('conda:package', res)]
        else:
            return []

    def resolve_xref(self, env: BuildEnvironment, fromdocname: str,
                     builder, role, target, node, contnode):
        """Resolve the ``pending_xref`` **node** with the given **role** and **target**."""
        for objtype in self.objtypes_for_role(role) or []:
            if (objtype, target) in self.data['objects']:
                node = make_refnode(
                    builder, fromdocname,
                    self.data['objects'][objtype, target][0],
                    self.data['objects'][objtype, target][1],
                    contnode, target + ' ' + objtype)
                node.set_class('conda-package')
                return node

            if objtype == "package":
                for channel, urlformat in env.app.config.bioconda_other_channels.items():
                    if RepoData().get_package_data(channels=channel, name=target):
                        uri = urlformat.format(target)
                        node = nodes.reference('', '', internal=False,
                                               refuri=uri, classes=[channel])
                        node += contnode
                        return node

        return None  # triggers missing-reference

    def get_objects(self):
        """Yields "object description" 5-tuples

        ``name``:     fully qualified name
        ``dispname``: name to display when searching/linking
        ``type``:     object type, a key in ``self.object_types``
        ``docname``:  the document where it is to be found
        ``anchor``:   the anchor name for the object
        ``priority``: search priority

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


class AutoRecipesDirective(rst.Directive):
    """FIXME: This does not yet do ANYTHING!

    In theory, a directive like this should act as a hook for a repo
    to generate stubs for, similar to other autoXYZ directives.
    """
    required_arguments = 0
    optional_argument = 0
    option_spec = {
        'repo': rst.directives.unchanged,
        'folder': rst.directives.unchanged,
        'config': rst.directives.unchanged,
    }
    has_content = False

    def run(self):
        #self.env: BuildEnvironment = self.state.document.settings.env
        return [nodes.paragraph('')]


def generate_readme(recipe_basedir, output_dir, folder, repodata, renderer):
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
    output_file = op.join(output_dir, folder, 'README.rst')

    # Select meta yaml
    meta_fname = op.join(recipe_basedir, folder, 'meta.yaml')
    if not op.exists(meta_fname):
        for item in os.listdir(op.join(recipe_basedir, folder)):
            dname = op.join(recipe_basedir, folder, item)
            if op.isdir(dname):
                fname = op.join(dname, 'meta.yaml')
                if op.exists(fname):
                    meta_fname = fname
                    break
        else:
            logger.error("No 'meta.yaml' found in %s", folder)
            return []
    meta_relpath = meta_fname[len(recipe_basedir)+1:]

    # Read the meta.yaml file(s)
    try:
        recipe = Recipe.from_file(recipe_basedir, meta_fname)
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
        'about': recipe.get('about', None),
        'extra': recipe.get('extra', None),
        'recipe': recipe,
        'packages': packages,
    }

    renderer.render_to_file(output_file, 'readme.rst_t', template_options)
    return [output_file]


def generate_recipes(app):
    """Generates recipe RST files

    - Checks out repository
    - Prepares `RepoData`
    - Selects recipes (if `BIOCONDA_FILTER_RECIPES` in environment)
    - Dispatches calls to `generate_readme` for each recipe
    - Removes old RST files
    """
    source_dir = app.env.srcdir
    doctree_dir = app.env.doctreedir  # .../build/doctrees
    repo_dir = op.join(op.dirname(app.env.srcdir), "_bioconda_recipes")
    recipe_basedir = op.join(repo_dir, app.config.bioconda_recipes_path)
    repodata_cache_file = op.join(doctree_dir, 'RepoDataCache.pkl')
    repo_config_file = os.path.join(repo_dir, app.config.bioconda_config_file)
    output_dir = op.join(source_dir, 'recipes')

    # Initialize Repo and point globals at the right place
    repo = BiocondaRepo(folder=repo_dir, home=app.config.bioconda_repo_url)
    repo.checkout_master()
    load_config(repo_config_file)
    logger.info("Preloading RepoData")
    repodata = RepoData()
    repodata.set_cache(repodata_cache_file)
    repodata.df  # pylint: disable=pointless-statement
    logger.info("Preloading RepoData (done)")

    # Collect recipe names
    recipe_dirs = os.listdir(recipe_basedir)
    if 'BIOCONDA_FILTER_RECIPES' in os.environ:
        limiter = os.environ['BIOCONDA_FILTER_RECIPES']
        try:
            recipe_dirs = recipe_dirs[:int(limiter)]
        except ValueError:
            match = re.compile(limiter)
            recipe_dirs = [recipe for recipe in recipe_dirs
                           if match.search(recipe)]

    # Set up renderer preparing recipe readme.rst files
    recipe_base_url = "{base}/tree/master/{recipes}/".format(
        base=app.config.bioconda_repo_url.rstrip(".git"),
        recipes=app.config.bioconda_recipes_path
    )
    renderer = Renderer(app, {'gh_recipes': recipe_base_url})

    recipes: List[str] = []

    if parallel_available and len(recipe_dirs) > 5:
        nproc = app.parallel
    else:
        nproc = 1

    if nproc == 1:
        for folder in status_iterator(
                recipe_dirs,
                'Generating package READMEs...',
                "purple", len(recipe_dirs), app.verbosity):
            if not op.isdir(op.join(recipe_basedir, folder)):
                logger.error("Item '%s' in recipes folder is not a folder",
                             folder)
                continue
            recipes.extend(generate_readme(recipe_basedir, output_dir, folder, repodata, renderer))
    else:
        tasks = ParallelTasks(nproc)
        chunks = make_chunks(recipe_dirs, nproc)

        def process_chunk(chunk):
            _recipes: List[Dict[str, Any]] = []
            for folder in chunk:
                if not op.isdir(op.join(recipe_basedir, folder)):
                    logger.error("Item '%s' in recipes folder is not a folder",
                                 folder)
                    continue
                _recipes.extend(generate_readme(recipe_basedir, output_dir, folder, repodata, renderer))
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

    files_wanted = set(recipes)
    for root, dirs, files in os.walk(output_dir, topdown=False):
        for fname in files:
            path = op.join(root, fname)
            if path not in files_wanted:
                os.unlink(path)
        for dname in dirs:
            try:
                os.rmdir(op.join(root, dname))
            except OSError:
                pass


def add_ribbon(app, pagename, templatename, context, doctree):
    """Adds "Edit me on GitHub" Ribbon to pages

    This hooks into ``html-page-context`` event and adds the parameters
    ``git_ribbon_url`` and ``git_ribbon_message`` to the context from
    which the HTML templates (``layout.html``) are expanded.

    It understands three types of pages:

    - ``_autosummary`` and ``_modules`` prefixed pages are assumed to
      be code and link to the ``bioconda-utils`` repo
    - ``recipes/*/README`` pages are assumed to be recipes and link
      to the ``meta.yaml``
    - all others are assumed to be RST docs and link to the ``docs/source/``
      folder in ``bioconda-utils``

    TODO:
      Fix hardcoding of values, should be a mapping that comes from
      ``conf.py``.

    """
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


class LintDescriptionDirective(SphinxDirective):
    required_arguments = 1
    optional_argument = 0
    has_content = True
    add_index = True

    def run(self):
        if not hasattr(self.env, 'bioconda_lint_checks'):
            self.env.bioconda_lint_checks = {str(check): check for check in get_checks()}
        # gather data
        check_name = self.arguments[0]
        if check_name not in self.env.bioconda_lint_checks:
            self.error("Duplicate lint description")
        check = self.env.bioconda_lint_checks.pop(check_name)
        _, lineno = inspect.getsourcelines(check)
        lineno += 1
        fname = inspect.getfile(check)
        doclines = inspect.getdoc(check).splitlines()
        docline_src = [(fname, i)
                       for i in range(lineno, lineno+len(doclines))]
        lines = StringList(doclines, items=docline_src)

        # create a new section with title
        section = nodes.section(ids=[nodes.make_id(check_name)])
        title_text = f'":py:class:`{check_name}`"'
        title_nodes, messages = self.state.inline_text(title_text, self.lineno)
        title = nodes.title(check_name, '', *title_nodes)
        section += title

        admonition = nodes.admonition()
        title_text = doclines[0].rstrip('.')
        title_nodes, messages = self.state.inline_text(title_text, lineno)
        title = nodes.title(title_text, '', *title_nodes)
        admonition += title
        admonition += messages
        self.state.nested_parse(lines[1:], 0, admonition)
        section += admonition

        # add remaining content of directive
        par = nodes.paragraph()
        self.state.nested_parse(self.content, self.content_offset, par)
        section += par

        return [section]

    @classmethod
    def finalize(cls, app, env):
        if env.bioconda_lint_checks:
            for check in env.bioconda_lint_checks:
                logger.error("Undocumented lint checks: %s", check)


def setup(app):
    """Set up sphinx extension"""
    app.add_domain(CondaDomain)
    app.add_directive('autorecipes', AutoRecipesDirective)
    app.add_directive('lint-check', LintDescriptionDirective)
    app.connect('builder-inited', generate_recipes)
    app.connect('env-updated', LintDescriptionDirective.finalize)
    app.connect('missing-reference', resolve_required_by_xrefs)
    app.connect('html-page-context', add_ribbon)
    app.add_config_value('bioconda_repo_url', '', 'env')
    app.add_config_value('bioconda_recipes_path', 'recipes', 'env')
    app.add_config_value('bioconda_config_file', 'config.yml', 'env')
    app.add_config_value('bioconda_other_channels', {}, 'env')
    return {
        'version': "0.0.1",
        'parallel_read_safe': True,
        'parallel_write_safe': True
    }
