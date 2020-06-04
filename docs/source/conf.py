#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import os
import sys


# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
sys.path.insert(0, os.path.abspath('.'))

def setup(app):
    app.add_css_file("style.css")
    app.add_css_file("font-awesome-4.7.0/css/font-awesome.min.css")


# -- General configuration ------------------------------------------------

#needs_sphinx = '1.0'

extensions = [
    'bioconda_utils.sphinxext',

    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.mathjax',
    'sphinx.ext.ifconfig',
    'sphinx.ext.viewcode',
    'sphinx.ext.extlinks',
    'sphinx.ext.autosectionlabel',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.napoleon',
    'sphinx_autodoc_typehints',  # must be loaded after napoleon
    'celery.contrib.sphinx',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = 'Bioconda'
copyright = '2016-{}, The Bioconda Team'.format(datetime.datetime.now().year)
author = 'The Bioconda Team'
language = None

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
#today_fmt = '%B %d, %Y'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = ['build']

# The reST default role (used for this markup: `text`) to use for all
# documents.
default_role = "any"

# If true, '()' will be appended to :func: etc. cross-reference text.
#add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
#add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
#show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# A list of ignored prefixes for module index sorting.
#modindex_common_prefix = []

# If true, keep warnings as "system message" paragraphs in the built documents.
#keep_warnings = False

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True


# -- Options for HTML output ----------------------------------------------

html_theme = 'alabaster'

html_theme_options = {
    'logo': 'logo/bioconda_monochrome_small.png',
    'sidebar_includehidden': False,
    'show_related': True,
    'font_family': "Raleway, sans-serif",
    'head_font_family': "'Lato', sans-serif",
    'fixed_sidebar': True,
}

# The name for this set of Sphinx documents.  If None, it defaults to
# "<project> v<release> documentation".
#html_title = None

# A shorter title for the navigation bar.  Default is the same as html_title.
#html_short_title = None

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
#html_logo = '../logo/bioconda_monochrome_small.png'

# The name of an image file (within the static path) to use as favicon of the
# docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
#html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['static']

# Add any extra paths that contain custom files (such as robots.txt or
# .htaccess) here, relative to this directory. These files are copied
# directly to the root of the documentation.
#html_extra_path = []

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
#html_last_updated_fmt = '%b %d, %Y'

# If true, SmartyPants will be used to convert quotes and dashes to
# typographically correct entities.
#html_use_smartypants = True

# Custom sidebar templates, maps document names to template names.
html_sidebars = {
    '**': [
        'about.html',
        'navigation.html',
        'index.html',
        'searchbox.html',
    ]
}

html_context = {
    'extra_nav_items': {
        'Bioconda @ Github' : 'https://github.com/bioconda/bioconda-recipes',
        'Package Index': 'conda-package_index',
        '<img alt="Gitter" src="https://img.shields.io/gitter/room/bioconda/Lobby.svg">':
        'https://gitter.im/bioconda/Lobby'
    }
}

# Additional templates that should be rendered to pages, maps page names to
# template names.
#html_additional_pages = {}

# If false, no module index is generated.
#html_domain_indices = True

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
#html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
#html_show_copyright = True

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
#html_use_opensearch = ''

# This is the file name suffix for HTML files (e.g. ".xhtml").
#html_file_suffix = None

# Language to be used for generating the HTML full-text search index.
# Sphinx supports the following languages:
#   'da', 'de', 'en', 'es', 'fi', 'fr', 'h', 'it', 'ja'
#   'nl', 'no', 'pt', 'ro', 'r', 'sv', 'tr'
#html_search_language = 'en'

# A dictionary with options for the search language support, empty by default.
# Now only 'ja' uses this config value
#html_search_options = {'type': 'default'}

# The name of a javascript file (relative to the configuration directory) that
# implements a search results scorer. If empty, the default will be used.
#html_search_scorer = 'scorer.js'

# Output file base name for HTML help builder.
htmlhelp_basename = 'bioconda-recipesdoc'

# -- Options for LaTeX output ---------------------------------------------

latex_elements = {
# The paper size ('letterpaper' or 'a4paper').
#'papersize': 'letterpaper',

# The font size ('10pt', '11pt' or '12pt').
#'pointsize': '10pt',

# Additional stuff for the LaTeX preamble.
#'preamble': '',

# Latex figure (float) alignment
#'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'bioconda-recipes.tex', 'bioconda-recipes Documentation',
     'bioconda', 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#latex_logo = None

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#latex_use_parts = False

# If true, show page references after internal links.
#latex_show_pagerefs = False

# If true, show URL addresses after external links.
#latex_show_urls = False

# Documents to append as an appendix to all manuals.
#latex_appendices = []

# If false, no module index is generated.
#latex_domain_indices = True


# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'bioconda-recipes', 'bioconda-recipes Documentation',
     [author], 1)
]

# If true, show URL addresses after external links.
#man_show_urls = False


# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
    (master_doc, 'bioconda-recipes', 'bioconda-recipes Documentation',
     author, 'bioconda-recipes', 'One line description of project.',
     'Miscellaneous'),
]

# Documents to append as an appendix to all manuals.
#texinfo_appendices = []

# If false, no module index is generated.
#texinfo_domain_indices = True

# How to display URL addresses: 'footnote', 'no', or 'inline'.
#texinfo_show_urls = 'footnote'

# If true, do not generate a @detailmenu in the "Top" node's menu.
#texinfo_no_detailmenu = False


# Example configuration for intersphinx: refer to the Python standard library.
intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
    'conda.io': ('https://conda.io/en/latest', None),
    'conda-build': ('https://conda.io/projects/conda-build/en/latest/', None),
    'conda': ('https://conda.io/projects/conda/en/latest/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}

# We are using the `extlinks` extension to render links for identifiers:
extlinks = {
    'biotools': ('https://bio.tools/%s', ''),
    'doi': ('https://doi.org/%s', ''),
    'debian': ('https://tracker.debian.org/pkg/%s', ''),
}

# add document name before automatic section title reference
autosectionlabel_prefix_document = True

# autogenerate autodoc stubs via autosummary
autosummary_generate = True

# combine docstrings for __init__ and class:
autoclass_content = "both"

# keep order from file (options: alphabetical, groupwise (by type), source)
autodoc_member_order = "source"

# default flags for autodoc statements
autodoc_default_flags = ['members', 'show-inheritance']

# autodoc_type_hints: set typing.TYPE_CHECKING to True while building docs
set_type_checking_flag = True

# Bioconda Sphinx Extension Config:
# Git Url for repository containing recipes
bioconda_repo_url = 'https://github.com/bioconda/bioconda-recipes.git'

# Path within that repository to folder containing recipes
# bioconda_recipes_path = 'recipes'

# Path within that repository to bioconda config file
# bioconda_config_file = 'config.yml'

# Formats for linkout to other channels
bioconda_other_channels = {
    'conda-forge': 'https://github.com/conda-forge/{}-feedstock'
}
