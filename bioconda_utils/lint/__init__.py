"""Recipe Linter

.. rubric:: Environment Variables

.. envvar:: LINT_SKIP

   If set, will be parsed instead of the most recent commit. To skip
   checks for specific recipes, add strings of the following form::

       [lint skip <check_name> for <recipe_name>]


.. autosummary::
   :toctree:

   checks

"""

import abc
import os
import re
import itertools
import logging
from collections import defaultdict
from enum import Enum
from typing import Any, Dict, List, NamedTuple, Tuple

import pandas as pd
import ruamel_yaml as yaml
import networkx as nx

from .. import utils
from ..recipe import Recipe, RecipeError

logger = logging.getLogger(__name__)


class Severity(Enum):
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
    recipe: Recipe

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


def get_checks():
    """Returns the registered lint checks"""
    return LintCheckMeta.registry


class LintCheck(metaclass=LintCheckMeta):
    """Base class for lint checks"""
    severity = ERROR
    requires = []

    def __init__(self, _linter: 'Linter') -> None:
        self.messages: List[LintMessage] = []
        self.recipe: Recipe = None

    def test(self):
        print('test')

    def __str__(self):
        return self.__class__.__name__

    def run(self, recipe: Recipe) -> List[LintMessage]:
        """Run the check on a recipe. Called by Linter"""
        self.messages: List[LintMessage] = []
        self.recipe: Recipe = recipe

        # Run general checks
        self.check_recipe(recipe)

        # Run per source checks
        source = recipe.get('source', None)
        if isinstance(source, dict):
            self.check_source(source, 'source')
        elif isinstance(source, list):
            for n, src in enumerate(source):
                self.check_source(src, f'source/{n}')

        # Run depends checks
        self.check_deps(recipe.get_deps_dict())

        return self.messages

    def check_recipe(self, recipe: Recipe) -> None:
        """Execute check on recipe

        Override this method in subclasses, using ``self.message()``
        to issue `LintMessage` as failures are encountered.
        """

    def check_source(self, source: Dict, section: str) -> None:
        """Execute check on each source"""

    def check_deps(self, deps: Dict[str, List[str]]) -> None:
        """Execute check on recipe dependencies"""

    def message(self, section: str = None, fname: str = None, line=None) -> None:
        """Add a message to the lint results

        Args:
          section: If specified, a lint location within the recipe
                   meta.yaml pointing to this section/subsection will
                   be added to the message
        """
        cls = self.__class__
        title, body = cls.__doc__.split('\n', 1)
        if section:
            try:
                sl, sc, el, ec = self.recipe.get_raw_range(section)
            except KeyError:
                sl, sc, el, ec = 1, 1, 1, 1
            if ec == 0:
                el = el - 1
            start_line = sl
            end_line = el
        else:
            start_line = end_line = line

        if not fname:
            fname = self.recipe.path

        message = LintMessage(recipe=self.recipe,
                              check=cls,
                              severity=self.severity,
                              title=title.strip(),
                              body=body.strip(),
                              fname=fname,
                              start_line=start_line,
                              end_line=end_line)

        self.messages.append(message)


from . import checks


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
    """
    def __init__(self, config, recipe_folder: str, exclude=None):
        self.config = config
        self.recipe_folder = recipe_folder
        self.skip = self.load_skips()
        self.exclude = exclude or []

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
        self.check_instances = {str(check): check(self) for check in get_checks()}

    def get_blacklist(self):
        return utils.get_blacklist(self.config, self.recipe_folder)

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
        else:
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

    def lint(self, recipe_names: List[str]) -> List[LintMessage]:
        return [message
                for recipe in utils.tqdm(sorted(recipe_names))
                for message in self.lint_one(recipe)]

    def lint_one(self, recipe_name: str) -> List[LintMessage]:
        # FIXME: rewrite each RecipeError to proper LintMessage
        try:
            recipe = Recipe.from_file(self.recipe_folder, recipe_name)
        except RecipeError as exc:
            title, body = exc.__class__.__doc__.split('\n', 1)
            message = LintMessage(recipe=Recipe(recipe_name, self.recipe_folder),
                                  check=exc,
                                  severity=ERROR,
                                  title=title,
                                  body=body)
            return [message]

        # collect checks to skip
        checks_to_skip = set(self.skip[recipe_name])
        checks_to_skip.update(self.exclude)
        if isinstance(recipe.get('extra/skip-lints', []), list):
            # If they are not, the extra_skip_lints_not_list check
            # will be found and issued.
            checks_to_skip.update(recipe.get('extra/skip-lints', []))

        # also skip dependent checks
        for check in checks_to_skip:
            if check not in self.checks_dag:
                logger.error("Skipping unknown check %s", check)
                continue
            for check_dep in nx.descendants(self.checks_dag, check):
                if check_dep not in checks_to_skip:
                    logger.info("Disabling %s because %s is disabled",
                                check_dep, check)
                checks_to_skip.add(check_dep)

        # run checks
        messages = []
        for check in self.checks_ordered:
            if str(check) in checks_to_skip:
                continue
            res = self.check_instances[check].run(recipe)
            if res:  # skip checks depending on failed checks
                checks_to_skip.update(nx.ancestors(self.checks_dag, str(check)))
            messages.extend(res)

        for message in messages:
            logger.debug(message)

        return messages


def markdown_report(report=None):
    """
    Return a rendered Markdown string.

    Parameters
    ----------
    report : None or pandas.DataFrame
        If None, linting assumed to be successful. If dataframe, it's provided
        to the lint failure template.
    """
    if not report:
        tmpl = utils.jinja.get_template("lint_success.md")
        return tmpl.render()

    by_recipe = {}
    for msg in report:
        by_recipe.setdefault(msg.recipe.path, []).append(msg)

    tmpl = utils.jinja.get_template("lint_failure.md")
    return tmpl.render(report=by_recipe)
