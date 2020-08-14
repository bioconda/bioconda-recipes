"""Recipe Linter

Writing additional checks
~~~~~~~~~~~~~~~~~~~~~~~~~

Lint checks are defined in :py:mod:`bioconda_utils.lint.checks` as
subclasses of `LintCheck`. It might be easiest to have a look at that
module and the already existing checks and go from there.

Briefly, each class becomes a check by:

- The class name becomes the name of the check in the documentation
  and when skipping lints. The convention is to use lower case
  separated by underscore.

- The docstring is used to describe the check on the command line,
  on Github when the check fails and in the documentation.

  The first line is considered a title or one line summary used where
  a brief description is needed. The remainder is a long desription
  and should include brief help on how to fix the detected issue.

- The class property ``severity`` defaults to ``ERROR`` but can be
  set to ``INFO`` or ``WARNING`` for informative checks that
  should not cause linting to fail.

- The class property ``requires`` may contain a list of other check
  classes that are required to have passed before this check is
  executed. Use this to avoid duplicate errors presented, or to
  ensure that asumptions made by your check are met by the recipe.

- Each class is instantiated once per linting run. Do slow preparation
  work in the constructor. E.g. the `recipe_is_blacklisted` check
  loads and parses the blacklist here.

- As each recipe is linted, your check will get called on three
  functions: `check_recipe <LintCheck.check_recipe>`, `check_deps
  <LintCheck.check_deps>` and `check_source <LintCheck.check_source>`.

  The first is simply passed the `Recipe` object, which you can use to
  inspect the recipe in question. The latter two are for convenience
  and performance. The ``check_deps`` call receives a mapping of
  all dependencies mentioned in the recipe to a list of locations
  in which the dependency occurred. E.g.::

    {'setuptools': ['requirements/run',
                    'outputs/0/requirements/run']}

  The ``check_sources`` is called for each source listed in the
  recipe, whether ``source:`` is a dict or a source, eliminating the
  need to repeat handling of these two cases in each check. The value
  ``source`` passed is a dictionary of the source, the value
  ``section`` a path to the source section.

- When a check encounters an issue, it should use ``self.message()`` to
  record the issue. The message is commonly modified with a path in
  the meta data to point to the part of the ``meta.yaml`` that lead to
  the error. This will be used to position annotations on github.

  If a check never calls ``self.message()``, it is assumed to have
  passed (=no errors generated).

  You can also provide an alternate filename (``fname``) and/or
  specify the line number directly (``line``).



Module Autodocs
~~~~~~~~~~~~~~~

.. rubric:: Environment Variables

.. envvar:: LINT_SKIP

   If set, will be parsed instead of the most recent commit. To skip
   checks for specific recipes, add strings of the following form::

       [lint skip <check_name> for <recipe_name>]


.. autosummary::
   :toctree:

   check_build_help
   check_completeness
   check_deprecation
   check_noarch
   check_policy
   check_repo
   check_syntax

"""

import abc
import os
import pkgutil
import re
import itertools
import logging
import inspect
import importlib
from collections import defaultdict
from enum import IntEnum
from typing import Any, Dict, List, NamedTuple, Set, Tuple

import pandas as pd
import ruamel_yaml as yaml
import networkx as nx

from .. import utils
from .. import recipe as _recipe


logger = logging.getLogger(__name__)


class Severity(IntEnum):
    """Severities for lint checks"""
    #: Checks of this severity are purely informational
    INFO = 10

    #: Checks of this severity indicate possible problems
    WARNING = 20

    #: Checks of this severity must be fixed and will fail a recipe.
    ERROR = 30

INFO = Severity.INFO
WARNING = Severity.WARNING
ERROR = Severity.ERROR


class LintMessage(NamedTuple):
    """Message issued by LintChecks"""

    #: The recipe this message refers to
    recipe: _recipe.Recipe

    #: The check issuing the message
    check: 'LintCheck'

    #: The severity of the message
    severity: Severity = ERROR

    #: Message title to be presented to user
    title: str = ""

    #: Message body to be presented to user
    body: str = ""

    #: Line at which problem begins
    start_line: int = 0

    #: Line at which problem ends
    end_line: int = 0

    #: Name of file in which error was found
    fname: str = "meta.yaml"

    #: Whether the problem can be auto fixed
    canfix: bool = False

    def get_level(self):
        """Return level string as required by github"""
        if self.severity < WARNING:
            return "notice"
        if self.severity < ERROR:
            return "warning"
        return "failure"


class LintCheckMeta(abc.ABCMeta):
    """Meta class for lint checks

    Handles registry
    """

    registry: List["LintCheck"] = []

    def __new__(cls, name: str, bases: Tuple[type, ...],
                namespace: Dict[str, Any], **kwargs) -> type:
        """Creates LintCheck classes"""
        typ = super().__new__(cls, name, bases, namespace, **kwargs)
        if name != "LintCheck":  # don't register base class
            cls.registry.append(typ)
        return typ

    def __str__(cls):
        return cls.__name__

_checks_loaded = False
def get_checks():
    """Loads and returns the available lint checks"""
    global _checks_loaded
    if not _checks_loaded:
        for _loader, name, _ispkg in pkgutil.iter_modules(__path__):
            if name.startswith('check_'):
                importlib.import_module(__name__ + '.' + name)
        _checks_loaded = True
    return LintCheckMeta.registry


class LintCheck(metaclass=LintCheckMeta):
    """Base class for lint checks"""

    #: Severity of this check. Only ERROR causes a lint failure.
    severity: Severity = ERROR

    #: Checks that must have passed for this check to be executed.
    requires: List['LintCheck'] = []

    def __init__(self, _linter: 'Linter') -> None:
        #: Messages collected running tests
        self.messages: List[LintMessage] = []
        #: Recipe currently being checked
        self.recipe: _recipe.Recipe = None
        #: Whether we are supposed to fix
        self.try_fix: bool = False

    def __str__(self):
        return self.__class__.__name__

    def run(self, recipe: _recipe.Recipe, fix: bool = False) -> List[LintMessage]:
        """Run the check on a recipe. Called by Linter

        Args:
          recipe: The recipe to be linted
          fix: Whether to attempt to fix the recipe
        """
        self.messages: List[LintMessage] = []
        self.recipe: _recipe.Recipe = recipe
        self.try_fix = fix

        # Run general checks
        self.check_recipe(recipe)

        # Run per source checks
        source = recipe.get('source', None)
        if isinstance(source, dict):
            self.check_source(source, 'source')
        elif isinstance(source, list):
            for num, src in enumerate(source):
                self.check_source(src, f'source/{num}')

        # Run depends checks
        self.check_deps(recipe.get_deps_dict())

        return self.messages

    def check_recipe(self, recipe: _recipe.Recipe) -> None:
        """Execute check on recipe

        Override this method in subclasses, using ``self.message()``
        to issue `LintMessage` as failures are encountered.

        Args:
          recipe: The recipe under test.
        """

    def check_source(self, source: Dict, section: str) -> None:
        """Execute check on each source

        Args:
          source: Dictionary containing the source section
          section: Path to the section. Can be ``source`` or
                   ``source/0`` (1,2,3...).
        """

    def check_deps(self, deps: Dict[str, List[str]]) -> None:
        """Execute check on recipe dependencies

        Example format for **deps**::

            {
              'setuptools': ['requirements/run',
                             'outputs/0/requirements/run/1'],
              'compiler_cxx': ['requirements/build/0']
            }

        You can use the values in the list directly as ``section``
        parameter to ``self.message()``.

        Args:
          deps: Dictionary mapping requirements occurring in the recipe
                to their locations within the recipe.
        """

    def fix(self, message, data) -> LintMessage:
        """Attempt to fix the problem"""

    def message(self, section: str = None, fname: str = None, line: int = None,
                data: Any = None) -> None:
        """Add a message to the lint results

        Also calls `fix` if we are supposed to be fixing.

        Args:
          section: If specified, a lint location within the recipe
                   meta.yaml pointing to this section/subsection will
                   be added to the message
          fname: If specified, the message will apply to this file, rather than the
                 recipe meta.yaml
          line: If specified, sets the line number for the message directly
          data: Data to be passed to `fix`. If check can fix, set this to
                something other than None.
        """
        message = self.make_message(self.recipe, section, fname, line,
                                    data is not None)
        if data is not None and self.try_fix and self.fix(message, data):
            return
        self.messages.append(message)

    @classmethod
    def make_message(cls, recipe: _recipe.Recipe, section: str = None,
                     fname: str = None, line=None, canfix: bool=False) -> LintMessage:
        """Create a LintMessage

        Args:
          section: If specified, a lint location within the recipe
                   meta.yaml pointing to this section/subsection will
                   be added to the message
          fname: If specified, the message will apply to this file, rather than the
                 recipe meta.yaml
          line: If specified, sets the line number for the message directly
        """
        doc = inspect.getdoc(cls)
        doc = doc.replace('::', ':').replace('``', '`')
        title, _, body = doc.partition('\n')
        if section:
            try:
                sl, sc, el, ec = recipe.get_raw_range(section)
            except KeyError:
                sl, sc, el, ec = 1, 1, 1, 1
            if ec == 0:
                el = el - 1
            start_line = sl
            end_line = el
        else:
            start_line = end_line = line or 0

        if not fname:
            fname = recipe.path

        return LintMessage(recipe=recipe,
                           check=cls,
                           severity=cls.severity,
                           title=title.strip(),
                           body=body,
                           fname=fname,
                           start_line=start_line,
                           end_line=end_line,
                           canfix=canfix)


class linter_failure(LintCheck):
    """An unexpected exception was raised during linting

    Please file an issue at the bioconda-utils repo
    """


class duplicate_key_in_meta_yaml(LintCheck):
    """The recipe meta.yaml contains a duplicate key

    This is invalid YAML, as it's unclear what the structure should
    become. Please merge the two offending sections
    """


class missing_version_or_name(LintCheck):
    """The recipe is missing name and/or version

    Please make sure the recipe has at least::

      package:
        name: package_name
        version: 0.12.34
    """


class empty_meta_yaml(LintCheck):
    """The recipe has an empty meta.yaml!?

    Please check if you forgot to commit its contents.
    """


class missing_build(LintCheck):
    """The recipe is missing a build section.

    Please add::

      build:
        number: 0
    """


class unknown_selector(LintCheck):
    """The recipe failed to parse due to selector lines

    Please request help from @bioconda/core.
    """


class missing_meta_yaml(LintCheck):
    """The recipe is missing a meta.yaml file

    Most commonly, this is because the file was accidentally
    named ``meta.yml``. If so, rename it to ``meta.yaml``.
    """


class conda_render_failure(LintCheck):
    """The recipe was not understood by conda-build

    Please request help from @bioconda/core.
    """


class jinja_render_failure(LintCheck):
    """The recipe could not be rendered by Jinja2

    Check if you are missing quotes or curly braces in Jinja2 template
    expressions. (The parts with ``{{ something }}`` or ``{% set
    var="value" %}``).
    """


class unknown_check(LintCheck):
    """Something went wrong inside the linter

    Please request help from @bioconda/core
    """


#: Maps `_recipe.RecipeError` to `LintCheck`
recipe_error_to_lint_check = {
    _recipe.DuplicateKey: duplicate_key_in_meta_yaml,
    _recipe.MissingKey: missing_version_or_name,
    _recipe.EmptyRecipe: empty_meta_yaml,
    _recipe.MissingBuild: missing_build,
    _recipe.HasSelector: unknown_selector,
    _recipe.MissingMetaYaml: missing_meta_yaml,
    _recipe.CondaRenderFailure: conda_render_failure,
    _recipe.RenderFailure: jinja_render_failure,
}




class Linter:
    """Lint executor

    Arguments:
      config: Configuration dict as provided by `utils.load_config()`.
      recipe_folder: Folder which recipes are located.
      exclude: List of function names in ``registry`` to skip globally.
               When running on CI, this will be merged with anything
               else detected from the commit message or LINT_SKIP
               environment variable using the special string "[skip
               lint <function name> for <recipe name>]". While those
               other mechanisms define skipping on a recipe-specific
               basis, this argument can be used to skip tests for all
               recipes. Use sparingly.
      nocatch: Don't catch exceptions in lint checks and turn them into
               linter_error lint messages. Used by tests.
    """
    def __init__(self, config: Dict, recipe_folder: str,
                 exclude: List[str] = None, nocatch: bool=False) ->None:
        self.config = config
        self.recipe_folder = recipe_folder
        self.skip = self.load_skips()
        self.exclude = exclude or []
        self.nocatch = nocatch
        self._messages = []

        dag = nx.DiGraph()
        dag.add_nodes_from(str(check) for check in get_checks())
        dag.add_edges_from(
            (str(check), str(check_dep))
            for check in get_checks()
            for check_dep in check.requires
        )
        self.checks_dag = dag

        try:
            self.checks_ordered = nx.topological_sort(dag, reverse=True)
        except nx.NetworkXUnfeasible:
            raise RunTimeError("Cycle in LintCheck requirements!")
        self.reload_checks()

    def reload_checks(self):
        self.check_instances = {str(check): check(self) for check in get_checks()}

    def get_blacklist(self) -> Set[str]:
        """Loads the blacklist as per linter configuration"""
        return utils.get_blacklist(self.config, self.recipe_folder)

    def get_messages(self) -> List[LintMessage]:
        """Returns the lint messages collected during linting"""
        return self._messages

    def clear_messages(self):
        """Clears the lint messages stored in linter"""
        self._messages = []

    def get_report(self) -> str:
        return "\n".join(
            f"{msg.severity.name}: {msg.fname}:{msg.end_line}: {msg.check}: {msg.title}"
            for msg in self.get_messages()
        )

    def load_skips(self):
        """Parses lint skips

        If :envvar:`LINT_SKIP` or the most recent commit contains ``[
        lint skip <check_name> for <recipe_name> ]``, that particular
        check will be skipped.

        """
        skip_dict = defaultdict(list)

        commit_message = ""
        if 'LINT_SKIP' in os.environ:
            # Allow overwriting of commit message
            commit_message = os.environ['LINT_SKIP']
        elif os.path.exists('.git'):
            # Obtain commit message from last commit.
            commit_message = utils.run(
                ['git', 'log', '--format=%B', '-n', '1'], mask=False, loglevel=0
            ).stdout

        skip_re = re.compile(
            r'\[\s*lint skip (?P<func>\w+) for (?P<recipe>.*?)\s*\]')
        to_skip = skip_re.findall(commit_message)

        for func, recipe in to_skip:
            skip_dict[recipe].append(func)
        return skip_dict

    def lint(self, recipe_names: List[str], fix: bool = False) -> bool:
        """Run linter on multiple recipes

        Lint messages are collected in the linter. They can be retrieved
        with `get_messages` and the list cleared with `clear_messages`.

        Args:
          recipe_names: List of names of recipes to lint
          fix: Whether checks should attempt to fix detected issues

        Returns:
          True if issues with errors were found

        """
        for recipe_name in utils.tqdm(sorted(recipe_names)):
            try:
                msgs = self.lint_one(recipe_name, fix=fix)
            except Exception:
                if self.nocatch:
                    raise
                logger.exception("Unexpected exception in lint")
                recipe = _recipe.Recipe(recipe_name, self.recipe_folder)
                msgs = [linter_failure.make_message(recipe=recipe)]
            self._messages.extend(msgs)

        return any(message.severity >= ERROR
                   for message in self._messages)

    def lint_one(self, recipe_name: str, fix: bool = False) -> List[LintMessage]:
        """Run the linter on a single recipe

        Args:
          recipe_name: Mames of recipe to lint
          fix: Whether checks should attempt to fix detected issues

        Returns:
          List of collected messages
        """
        try:
            recipe = _recipe.Recipe.from_file(self.recipe_folder, recipe_name)
        except _recipe.RecipeError as exc:
            recipe = _recipe.Recipe(recipe_name, self.recipe_folder)
            check_cls = recipe_error_to_lint_check.get(exc.__class__, linter_failure)
            return [check_cls.make_message(
                recipe=recipe,
                line=getattr(exc, 'line')
            )]

        # collect checks to skip
        checks_to_skip = set(self.skip[recipe_name])
        checks_to_skip.update(self.exclude)
        if isinstance(recipe.get('extra/skip-lints', []), list):
            # If they are not, the extra_skip_lints_not_list check
            # will be found and issued.
            checks_to_skip.update(recipe.get('extra/skip-lints', []))

        # also skip dependent checks
        for check in list(checks_to_skip):
            if check not in self.checks_dag:
                logger.error("Skipping unknown check %s", check)
                continue
            for check_dep in nx.ancestors(self.checks_dag, check):
                if check_dep not in checks_to_skip:
                    logger.info("Disabling %s because %s is disabled",
                                check_dep, check)
                checks_to_skip.add(check_dep)

        # run checks
        messages = []
        for check in self.checks_ordered:
            if str(check) in checks_to_skip:
                continue
            try:
                res = self.check_instances[check].run(recipe, fix)
            except Exception:
                if self.nocatch:
                    raise
                logger.exception("Unexpected exception in lint_one")
                res = [LintMessage(
                    recipe=recipe,
                    check=check,
                    severity=ERROR,
                    title="Check raised an unexpected exception")
                ]

            if res:  # skip checks depending on failed checks
                checks_to_skip.update(nx.ancestors(self.checks_dag, str(check)))
            messages.extend(res)

        if fix and recipe.is_modified():
            with open(recipe.path, 'w', encoding='utf-8') as fdes:
                fdes.write(recipe.dump())

        for message in messages:
            logger.debug("Found: %s", message)

        return messages
