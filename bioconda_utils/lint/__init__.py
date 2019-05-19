"""
Recipe Linter

QC checks (linter) for recipes, returning a TSV of issues identified.

The strategy here is to use simple functions that do a single check on
a recipe. When run on a single recipe it can be used for linting new
contributions; when run on all recipes it helps highlight entire classes of
problems to be addressed.

See the `lint_functions` module for these.

After writing the function, register it in the global ``registry`` dict,
``lint_functions.registry``.

The output is a TSV where the "info" column contains the dicts returned by
each check function, and this column is expanded into multiple extra colums.
While this results in a lot of NaNs, it makes it easy to drop non-interesting
cases with pandas, e.g.,

.. code:: python

   recipes_with_missing_tests = df.dropna(subset=['no_tests'])

or

.. code:: python

    def not_in_bioconda(x):
        if not isinstance(x, set):
            return np.nan
        res = set(x).difference(['bioconda'])
        if len(res):
            return(res)
        return np.nan

    df['other'] = df.exists_in_channel.apply(not_in_bioconda)
    other_channels = df[['recipe', 'other']].dropna()
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

from .. import utils
from ..recipe import Recipe, RecipeError

logger = logging.getLogger(__name__)

Severity = Enum("Severity", "INFO WARNING ERROR")  # pylint: disable=invalid-name
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

    def __repr__(cls):
        return cls.__name__


def get_checks():
    """Returns the registered lint checks"""
    return LintCheckMeta.registry


class LintCheck(metaclass=LintCheckMeta):
    """Base class for lint checks"""
    severity = None
    def __init__(self, _linter: 'Linter') -> None:
        self.messages: List[LintMessage] = []
        self.recipe: Recipe = None

    def test(self):
        print('test')
        

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
      exclude: List of function names in ``registry`` to skip globally.
               When running on CI, this will be merged with anything
               else detected from the commit message or LINT_SKIP
               environment variable using the special string "[skip
               lint <function name> for <recipe name>]". While those
               other mechanisms define skipping on a recipe-specific
               basis, this argument can be used to skip tests for all
               recipes. Use sparingly.
      recipe_folder: Folder which recipes are located.
      registry: List of functions to apply to each recipe. If None, 
                defaults to `bioconda_utils.lint_functions.registry`.
    """
    def __init__(self, config, recipe_folder: str, exclude=None, include=None):
        self.config = config
        self.recipe_folder = recipe_folder
        self.skip = self.load_skips()
        exclude = set(exclude) if exclude is not None else None
        include = set(include) if include is not None else None
        self.checks = []
        for check in get_checks():
            # if we have include, it must be in include
            if include is not None and str(check) not in include:
                continue
            # if we have exclude it most NOT be in exclude
            if exclude is not None and str(check) in exclude:
                continue
            self.checks.append(check(self))

    def get_blacklist(self):
        return utils.get_blacklist(self.config, self.recipe_folder)

    def load_skips(self):
        """Parses lint skips

        If :env:`LINT_SKIP` or the most recent commit contains ``[
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

        skips = set(self.skip[recipe_name])
        skips.update(recipe.get('extra/skip-lints', []))

        messages = []
        for check in self.checks:
            if str(check) in skips:
                continue
            messages.extend(check.run(recipe))
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
