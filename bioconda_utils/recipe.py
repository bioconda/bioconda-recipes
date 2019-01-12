"""The **meta.yaml** format used by conda to describe how a package
is built has diverged from standard YAML format significantly. This
module implements a class `Recipe` that in contrast to the **Meta**
object resulting from parsing by **conda_build** offers functions to
edit the meta.yaml.
"""

import logging
import os
import re

from collections import defaultdict
from copy import copy
from typing import Any, Dict, List, Sequence, Optional, Pattern


try:
    from ruamel.yaml import YAML
    from ruamel.yaml.constructor import DuplicateKeyError
except ModuleNotFoundError:
    from ruamel_yaml import YAML
    from ruamel_yaml.constructor import DuplicateKeyError

from . import utils
from .async import EndProcessingItem


yaml = YAML(typ="rt")  # pylint: disable=invalid-name

# Hack: mirror stringify from conda-build in removing implicit
#       resolution of numbers
for digit in '0123456789':
    if digit in yaml.resolver.versioned_resolver:
        del yaml.resolver.versioned_resolver[digit]

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class RecipeError(EndProcessingItem):
    pass


class DuplicateKey(RecipeError):
    """Raised for recipes with duplicate keys in the meta.yaml. YAML
    does not allow those, but the PyYAML parser silently overwrites
    previous keys.

    For duplicate keys that are a result of `# [osx]` style line selectors,
    `Recipe` attempts to resolve them as a list of dictionaries instead.
    """
    template = "has duplicate key"


class MissingKey(RecipeError):
    """Raised if a recipe is missing package/version or package/name"""
    template = "has missing key"


class EmptyRecipe(RecipeError):
    """Raised if the recipe file is empty"""
    template = "is empty"


class MissingBuild(RecipeError):
    """Raised if the recipe is missing the build section"""
    template = "is missing build section"


class HasSelector(RecipeError):
    """Raised when recplacements fail due to `# [cond]` line selectors
    FIXME: This should no longer be an error
    """
    template = "has selector in line %i (replace failed)"


class Recipe():
    """Represents a recipe (meta.yaml) in editable form

    Using conda-build to render recipe is slow and a one-way
    process. We need to be able to load **and** save recipes, which is
    handled by the representation in this class.

    Recipes undergo two manipulation rounds before parsed as YAML:
     1. Selecting lines using ``# [expression]``
     2. Rendering as Jinja2 template

    (1) is currently unhandled, leading to recipes with repeated mapping keys
    (commonly two ``url`` keys). Those recipes are ignored for the time being.

    Arguments:
      recipe_folder: base recipes folder
      recipe_dir: path to specific recipe
    """


    #: Variables to pass to Jinja when rendering recipe
    JINJA_VARS = {
        "cran_mirror": "https://cloud.r-project.org",
        "compiler": lambda x: f"compiler_{x}",
    }

    #: Name of key under ``extra`` containing config
    EXTRA_CONFIG = "autobump"

    def __init__(self, recipe_dir, recipe_folder):
        if not recipe_dir.startswith(recipe_folder):
            raise RuntimeError(f"'{recipe_dir}' not inside '{recipe_folder}'")

        #: path to folder containing recipes
        self.basedir = recipe_folder
        #: relative path to recipe dir from folder containing recipes
        self.reldir = recipe_dir[len(recipe_folder):].strip("/")

        # Filled in by render()
        #: Parsed recipe YAML
        self.meta: Dict[str, Any] = {}

        # These will be filled in by load_from_string()
        #: Lines of the raw recipe file
        self.meta_yaml: List[str] = []
        # Filled in by update filter
        self.version_data: Dict[str, Any] = None
        #: Original recipe before modifications (updated by load_from_string)
        self.orig: Recipe = copy(self)
        #: Whether the recipe was loaded from a branch (update in progress)
        self.on_branch: bool = False

    @property
    def path(self):
        """Full path to `meta.yaml``"""
        return os.path.join(self.basedir, self.reldir, "meta.yaml")

    @property
    def config(self):
        """Per-recipe configuration parameters

        These are the values set in ``extra:`` under the key
        defined as `Recipe.EXTRA_CONFIG` (default is ``watch``).
        """
        return self.meta.get("extra", {}).get(self.EXTRA_CONFIG, {})

    def __str__(self) -> str:
        return self.reldir

    def load_from_string(self, data) -> "Recipe":
        """Load and `render` recipe contents from disk"""
        self.meta_yaml = data.splitlines()
        if not self.meta_yaml:
            raise EmptyRecipe(self)
        self.render()
        return self

    def set_original(self) -> None:
        """Store the current state of the recipe as "original" version"""
        self.orig = copy(self)

    def dump(self):
        """Dump recipe content"""
        return "\n".join(self.meta_yaml) + "\n"

    @staticmethod
    def _rewrite_selector_block(text, block_top, block_left):
        if not block_left:
            return None  # never the whole yaml
        lines = text.splitlines()
        block_height = None
        variants: Dict[str, List[str]] = defaultdict(list)

        for block_height, line in enumerate(lines[block_top:]):
            if line.strip() and not line.startswith(" " * block_left):
                break
            _, _, selector = line.partition("#")
            if selector:
                variants[selector.strip("[] ")].append(line)
            else:
                for variant in variants:
                    variants[variant].append(line)
        else:
            # end of file, need to add one to block height
            block_height += 1

        if not block_height:  # empty lines?
            return None
        if not variants:
            return None
        if any(" " in v for v in variants):
            # can't handle "[py2k or osx]" style things
            return None

        new_lines = []
        for variant in variants.values():
            first = True
            for line in variant:
                if first:
                    new_lines.append("".join((" " * block_left, "- ", line)))
                    first = False
                else:
                    new_lines.append("".join((" " * (block_left + 2), line)))

        logger.debug("Replacing: lines %i - %i with %i lines:\n%s\n---\n%s",
                     block_top, block_top+block_height, len(new_lines),
                     "\n".join(lines[block_top:block_top+block_height]),
                     "\n".join(new_lines))

        lines[block_top:block_top+block_height] = new_lines
        return "\n".join(lines)

    def get_template(self):
        """Create a Jinja2 template from the current raw recipe"""
        # This function exists because the template cannot be pickled.
        # Storing it means the recipe cannot be pickled, which in turn
        # means we cannot pass it to ProcessExecutors.
        return utils.jinja_silent_undef.from_string(
            "\n".join(self.meta_yaml)
        )

    def get_simple_modules(self):
        """Yield simple replacement values from template

        E.g. those set with ``{% set version='1.2.3' %}```

        Returns:
          a dictionary of replacements (e.g. version: 1.2.3)
        """
        template = self.get_template()
        return {
            attr: getattr(template.module, attr)
            for attr in dir(template.module)
            if not attr.startswith("_")
            and not hasattr(getattr(template.module, attr), '__call__')
        }

    def render(self) -> None:
        """Convert recipe text into data structure

        - create jinja template from recipe content
        - render template
        - parse yaml
        - normalize
        """
        yaml_text = self.get_template().render(self.JINJA_VARS)
        try:
            self.meta = yaml.load(yaml_text)
        except DuplicateKeyError as err:
            logger.debug("fixing duplicate key at %i:%i",
                         err.context_mark.line, err.context_mark.column)
            # We may have encountered a recipe with linux/osx variants using line selectors
            yaml_text = self._rewrite_selector_block(yaml_text, err.context_mark.line,
                                                     err.context_mark.column)
            if yaml_text:
                try:
                    self.meta = yaml.load(yaml_text)
                except DuplicateKeyError:
                    raise DuplicateKey(self)
            else:
                raise DuplicateKey(self)

        if "package" not in self.meta \
           or "version" not in self.meta["package"] \
           or "name" not in self.meta["package"]:
            raise MissingKey(self)

        # make recipe-maintainers a list if it is a string
        maintainers = self.meta.mlget(["extra", "recipe-maintainers"])
        if maintainers and isinstance(maintainers, str):
            self.meta["extra"]["recipe-maintainers"] = [maintainers]

    @property
    def name(self) -> str:
        """The name of the toplevel package built by this recipe"""
        return self.meta["package"]["name"]

    @property
    def version(self) -> str:
        """The version of the package build by this recipe"""
        return str(self.meta["package"]["version"])

    @property
    def package_names(self) -> List[str]:
        """List of the packages built by this recipe (including outputs)"""
        packages = [self.name]
        if "outputs" in self.meta:
            packages.extend(output['name'] for output in self.meta['outputs'])
        return packages

    def replace(self, before: str, after: str,
                within: Sequence[str] = ("package", "source"),
                with_fuzz=False) -> int:
        """Runs string replace on parts of recipe text.

        - Lines considered are those containing Jinja set statements
        (``{% set var="val" %}``) and those defining the top level
        Mapping entries given by **within** (default:``package`` and
        ``source``).

        - Cowardly refuses to modify lines with ``# [expression]``
        selectors.
        """
        logger.debug("Trying to replace %s with %s", before, after)

        # get lines starting with "{%"
        lines = set()
        for lineno, line in enumerate(self.meta_yaml):
            if line.strip().startswith("{%"):
                lines.add(lineno)

        # get lines covered by keys listed in ``within``
        start: Optional[int] = None
        for key in self.meta.keys():
            lineno = self.meta.lc.key(key)[0]
            if key in within:
                if start is None:
                    start = lineno
            else:
                if start is not None:
                    lines.update(range(start, lineno))
                    start = None
        if start is not None:
            lines.update(range(start, len(self.meta_yaml)))

        if isinstance(before, Pattern):
            re_before = before
            re_select = re.compile(before.pattern + r".*#.*\[")
        else:
            before_pattern = re.escape(before)
            if with_fuzz:
                before_pattern = re.sub(r"(-|\\\.|_)", "[-_.]", before_pattern)
            re_before = re.compile(before_pattern)
            re_select = re.compile(before_pattern + r".*#.*\[")

        # replace within those lines, erroring on "# [asd]" selectors
        replacements = 0
        for lineno in sorted(lines):
            line = self.meta_yaml[lineno]
            if not re_before.search(line):
                continue
            if re_select.search(line):
                raise HasSelector(self, lineno)
            new = re_before.sub(after, line)
            logger.debug("%i - %s", lineno, self.meta_yaml[lineno])
            logger.debug("%i + %s", lineno, new)
            self.meta_yaml[lineno] = new
            replacements += 1
        return replacements

    def reset_buildnumber(self):
        """Resets the build number

        If the build number is missing, it is added after build.
        """
        try:
            lineno: int = self.meta["build"].lc.key("number")[0]
        except (KeyError, AttributeError):  # no build number?
            if "build" in self.meta and self.meta["build"] is not None:
                build = self.meta["build"]
                first_in_build = next(iter(build))
                lineno, colno = build.lc.key(first_in_build)
                self.meta_yaml.insert(lineno, " "*colno + "number: 0")
            else:
                raise MissingBuild(self)

        line = self.meta_yaml[lineno]
        line = re.sub("number: [0-9]+", "number: 0", line)
        self.meta_yaml[lineno] = line

    def get_raw_range(self, path):
        """Locate the position of a node in the YAML within the raw text


        See also `get_raw()` if you want to get the content of the unparsed
        meta.yaml at a specific key.

        Args:
          path: The "path" to the node. Use numbers for lists ('source/1/url')

        Returns:
          a tuple of first_row, first_column, last_row, last_column
        """
        nodes = [self.meta]
        keys = []
        # find items composing path
        for key in path.split("/"):
            last = nodes[-1]
            try:
                number = int(key)
                if isinstance(last, list):
                    nodes.append(last[number])
                    keys.append(number)
                elif isinstance(last, dict) and number == 0:
                    pass
                else:
                    raise ValueError(f"Can't access {path} in meta")
            except ValueError:
                nodes.append(last[key])
                keys.append(key)

        nodes.pop()  # pop parsed value

        # get the start row/col for the value
        if isinstance(keys[-1], int):
            start_row, start_col = nodes[-1].lc.key(keys[-1])
        else:
            start_row, start_col = nodes[-1].lc.value(keys[-1])

        # getting the end is more complicated, we need to move
        # up the tree to the next item in order until one is not the last
        # item in its collection
        while nodes:
            node = nodes.pop()
            key = keys.pop()
            if isinstance(key, int):
                if key + 1 < len(node):
                    end_row, end_col = node.lc.key(key + 1)
                    break
            else:
                node_keys = list(node.keys())
                if key != node_keys[-1]:
                    next_key = node_keys[node_keys.index(key)+1]
                    end_row, end_col = node.lc.key(next_key)
                    break
        else:
            end_row = len(self.meta_yaml)
            end_col = len(self.meta_yaml[-1])
        return (start_row, start_col, end_row, end_col)

    def get_raw(self, path):
        """Extracts the unparsed text for a node in the meta.yaml

        Args:
          path: Slash-separated path to the node. Numbers can be used
                to access indices in lists. A number '0' is ignored if
                the node is a dict (so 'source/0/url' will work even if
                there is only one url).

        Returns:
          Extracted raw text
        """
        start_row, start_col, end_row, end_col = self.get_raw_range(path)
        lines = []
        lines.append(self.meta_yaml[start_row][start_col:])
        for row in range(start_row+1, end_row):
            lines.append(self.meta_yaml[row])
        lines.append(self.meta_yaml[end_row][:end_col])
        return "\n".join(lines).strip()
