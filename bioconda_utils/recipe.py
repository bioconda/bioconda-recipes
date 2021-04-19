"""
Editable Recipe (``meta.yaml``)

The **meta.yaml** format used by conda to describe how a package
is built has diverged from standard YAML format significantly. This
module implements a class `Recipe` that in contrast to the **Meta**
object resulting from parsing by **conda_build** offers functions to
edit the meta.yaml.
"""

import logging
import os
import re
import sys
import tempfile
import types

from collections import defaultdict
from contextlib import redirect_stdout, redirect_stderr
from copy import deepcopy
from pathlib import Path
from typing import Any, Dict, List, Sequence, Tuple, Optional, Pattern


import conda_build.api
from conda_build.metadata import MetaData

import jinja2

try:
    from ruamel.yaml import YAML
    from ruamel.yaml.constructor import DuplicateKeyError
    from ruamel.yaml.error import YAMLError
except ModuleNotFoundError:
    from ruamel_yaml import YAML
    from ruamel_yaml.constructor import DuplicateKeyError
    from ruamel_yaml.error import YAMLError

from . import utils
from .aiopipe import EndProcessingItem


yaml = YAML(typ="rt")  # pylint: disable=invalid-name

# Hack: mirror stringify from conda-build in removing implicit
#       resolution of numbers
for digit in '0123456789':
    if digit in yaml.resolver.versioned_resolver:
        del yaml.resolver.versioned_resolver[digit]

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class RecipeError(EndProcessingItem):
    def __init__(self, item, message=None, line=None, column=None):
        self.line = line
        self.column = column
        if message is not None:
            if line is not None:
                if column is not None:
                    message += " (at line %i / column %i)" % (line, column)
                else:
                    message += " (at line %i)" % line
            super().__init__(item, message)
        else:
            super().__init__(item)


class DuplicateKey(RecipeError):
    """Raised for recipes with duplicate keys in the meta.yaml. YAML
    does not allow those, but the PyYAML parser silently overwrites
    previous keys.

    For duplicate keys that are a result of ``# [osx]`` style line selectors,
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
    """Raised when recplacements fail due to ``# [cond]`` line selectors
    FIXME: This should no longer be an error
    """
    template = "has selector in line %i (replace failed)"


class MissingMetaYaml(RecipeError):
    """Raised when FileNotFoundError is encountered

    self.item is NOT a Recipe but a str here
    """
    template = "has missing file `meta.yaml`"

class CondaRenderFailure(RecipeError):
    """Raised when conda_build.api.render fails"""
    template = "could not be rendered by conda-build: %s"


class RenderFailure(RecipeError):
    """Raised on Jinja rendering problems

    May have self.line
    """
    template = "failed to render in Jinja2. Error was: %s"


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
        "pin_compatible": lambda x, max_pin=None, min_pin=None: f"{x}",
        "cdt": lambda x: x
    }


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

        self.conda_build_config: str = ''
        self.build_scripts: Dict[str, str] = {}

        # These will be filled in by load_from_string()
        #: Lines of the raw recipe file
        self.meta_yaml: List[str] = []
        # Filled in by update filter
        self.version_data: Dict[str, Any] = {}
        #: Original recipe before modifications (updated by load_from_string)
        self.orig: Recipe = deepcopy(self)
        #: Whether the recipe was loaded from a branch (update in progress)
        self.on_branch: bool = False
        #: For passing data around
        self.data: Dict[str, Any] = {}

        # for conda_render() and conda_release()
        self._conda_meta = None
        self._conda_tempdir = None

    @property
    def path(self):
        """Full path to ``meta.yaml``"""
        return os.path.join(self.basedir, self.reldir, "meta.yaml")

    @property
    def relpath(self):
        """Relative path to ``meta.yaml`` (from ``basedir``)"""
        return os.path.join(self.reldir, "meta.yaml")

    @property
    def dir(self):
        """Path to recipe folder"""
        return os.path.join(self.basedir, self.reldir)

    def __str__(self) -> str:
        return self.reldir

    def __repr__(self) -> str:
        return f'{self.__class__.__name__} "{self.reldir}"'

    def load_from_string(self, data) -> "Recipe":
        """Load and `render` recipe contents from disk"""
        self.meta_yaml = data.splitlines()
        if not self.meta_yaml:
            raise EmptyRecipe(self)
        self.render()
        return self

    def read_conda_build_config(self):
        # Cache contents of conda_build_config.yaml for conda_render.
        path = Path(self.dir, 'conda_build_config.yaml')
        if path.is_file():
            self.conda_build_config = path.read_text()
        else:
            self.conda_build_config = ''

    def read_build_scripts(self):
        # Cache contents of build scripts for conda_render since conda-build
        # inspects build scripts for used variant variables.
        scripts = ['build.sh'] + [
            output.get('script') for output in self.meta.get('outputs') or ()
        ]
        self.build_scripts.clear()
        for script in scripts:
            if not script or os.path.sep in script:
                # Only support flat folder structure.
                continue
            try:
                path = Path(self.dir, script)
                content = path.read_text()
            except:
                continue
            self.build_scripts[script] = content

    @classmethod
    def from_file(cls, recipe_dir, recipe_fname, return_exceptions=False) -> "Recipe":
        """Create new `Recipe` object from file

        Args:
           recipe_dir: Path to recipes folder
           recipe_fname: Relative path to recipe (folder or meta.yaml)
        """
        if recipe_fname.endswith("meta.yaml"):
            recipe_fname = os.path.dirname(recipe_fname)
        recipe = cls(recipe_fname, recipe_dir)
        try:
            with open(os.path.join(recipe_fname, 'meta.yaml')) as text:
                recipe.load_from_string(text.read())
        except FileNotFoundError:
            exc = MissingMetaYaml(recipe_fname)
            if return_exceptions:
                return exc
            raise exc
        except Exception as exc:
            if return_exceptions:
                return exc
            raise exc
        try:
            recipe.read_conda_build_config()
        except Exception as exc:
            if return_exceptions:
                return exc
            raise exc
        try:
            recipe.read_build_scripts()
        except Exception as exc:
            if return_exceptions:
                return exc
            raise exc
        recipe.set_original()
        return recipe

    def save(self):
        with open(self.path, "w", encoding="utf-8") as fdes:
            fdes.write(self.dump())

    def set_original(self) -> None:
        """Store the current state of the recipe as "original" version"""
        self.orig = deepcopy(self)

    def is_modified(self) -> bool:
        return self.meta_yaml != self.orig.meta_yaml

    def dump(self):
        """Dump recipe content"""
        return "\n".join(self.meta_yaml) + "\n"

    @staticmethod
    def _rewrite_selector_block(text, block_top, block_left):
        if not block_left:
            return None  # never the whole yaml
        lines = text.splitlines()
        block_height = 0
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
        try:
            return utils.jinja_silent_undef.from_string(
                "\n".join(self.meta_yaml)
            )
        except jinja2.exceptions.TemplateSyntaxError as exc:
            raise RenderFailure(self, message=exc.message, line=exc.lineno)
        except jinja2.exceptions.TemplateError as exc:
            raise RenderFailure(self, message=exc.message)

    def get_simple_modules(self):
        """Yield simple replacement values from template

        E.g. those set with ``{% set version='1.2.3' %}```

        Returns:
          a dictionary of replacements (e.g. version: 1.2.3)
        """
        # unused
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
            line = err.problem_mark.line + 1
            column = err.problem_mark.column + 1
            logger.debug("fixing duplicate key at %i:%i", line, column)
            # We may have encountered a recipe with linux/osx variants using line selectors
            yaml_text = self._rewrite_selector_block(yaml_text, err.context_mark.line,
                                                     err.context_mark.column)
            if yaml_text:
                try:
                    self.meta = yaml.load(yaml_text)
                except DuplicateKeyError:
                    raise DuplicateKey(self, line=line, column=column)
            else:
                raise DuplicateKey(self, line=line, column=column)

        if "package" not in self.meta \
           or "version" not in self.meta["package"] \
           or "name" not in self.meta["package"]:
            raise MissingKey(self)

    @property
    def maintainers(self):
        """List of recipe maintainers"""
        if 'extra' in self.meta and 'recipe-maintainers' in self.meta['extra']:
            return utils.ensure_list(self.meta['extra']['recipe-maintainers'])
        return []

    @property
    def name(self) -> str:
        """The name of the toplevel package built by this recipe"""
        return self.meta["package"]["name"]

    @property
    def version(self) -> str:
        """The version of the package build by this recipe"""
        return str(self.meta["package"]["version"])

    @property
    def build_number(self) -> int:
        """The current build number"""
        return int(self.meta["build"]["number"])

    def __getitem__(self, key):
        return self.meta[key]

    def _walk(self, path, noraise=False):
        nodes = [self.meta]
        keys = []
        for key in path.split('/'):
            last = nodes[-1]
            if key.isdigit():
                number = int(key)
                if isinstance(last, list):
                    if noraise and len(last) < number:
                        break
                    nodes.append(last[number])
                    keys.append(number)
                    continue
                if isinstance(last, dict) and number == 0:
                    continue
            if noraise and key not in last:
                break
            nodes.append(last[key])
            keys.append(key)
        return nodes, keys

    def get_raw_range(self, path):
        """Locate the position of a node in the YAML within the raw text

        See also `get_raw()` if you want to get the content of the unparsed
        meta.yaml at a specific key.

        Args:
          path: The "path" to the node. Use numbers for lists ('source/1/url')

        Returns:
          a tuple of first_row, first_column, last_row, last_column
        """
        if not path:
            return 0, 0, len(self.meta_yaml), len(self.meta_yaml[-1])

        nodes, keys = self._walk(path)
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
        else:  # reached end of file
            end_row = len(self.meta_yaml) - 1
            end_col = len(self.meta_yaml[end_row])

        # now go backward
        return (start_row, start_col, end_row, end_col)

    def get_raw(self, path):
        """Extracts the unparsed text for a node in the meta.yaml

        This may contain separators and other characters from
        the yaml!

        Args:
          path: Slash-separated path to the node. Numbers can be used
                to access indices in lists. A number '0' is ignored if
                the node is a dict (so 'source/0/url' will work even if
                there is only one url).

        Returns:
          Extracted raw text
        """
        start_row, start_col, end_row, end_col = self.get_raw_range(path)
        if start_row == end_row:
            return self.meta_yaml[start_row][start_col:end_col]

        lines = []
        # first row
        lines.append(self.meta_yaml[start_row][start_col:])
        # middle rows if any
        for row in range(start_row + 1, end_row):
            lines.append(self.meta_yaml[row])
        lines.append(self.meta_yaml[end_row][:end_col])
        return "\n".join(lines).strip()

    def get(self, path: str, default: Any=KeyError) -> Any:
        """Get a value or section from the recipe

        >>> recipe.get('requirements/build')
        ['setuptools]
        >>> recipe.get('source/0/url')
        'https://somewhere'

        The **path** is a ``/`` separated list of dictionary keys to
        be walked in the recipe meta data. Numeric sections in the path
        access list elements. Using ``0`` in the path will get the first
        element in a list or the contents directly if there is no list.
        I.e., `source/0/url` will always get the first url, whether or
        not the source section is a list.

        Args:
          path: Path through YAML
          default: If not KeyError, this value will be returned
                   if the path does not exist in the recipe
        Raises:
          KeyError if no default given and the path does not exist.
        """
        try:
            nodes, keys = self._walk(path)
        except (KeyError, TypeError):
            if default is not KeyError:
                return default
            raise KeyError(f"No '{path}' in Recipe {self}") from None
        res = nodes[-1]
        if default is not KeyError and res is None:
            return default
        return res

    def set(self, path, value):
        """Set a value or section in the recipe

        See `get` for a description of how **path** works.
        """
        # walk path into nodes/keys
        nodes, keys = self._walk(path, noraise=True)

        # "mkdir -p"
        found_path = '/'.join(str(key) for key in keys)
        if found_path != path:
            _, col, row, _ = self.get_raw_range(found_path)
            backup = deepcopy(self.meta_yaml)
            for key in path.split('/')[len(keys):]:
                self.meta_yaml.insert(row, ' ' * col + key + ':')
                row += 1
                col += 2
            self.meta_yaml[row-1] += " marker"
            self.render()

        # get old content
        content = self.get(path)
        row, col, end_row, end_col = self.get_raw_range(path)
        self.meta_yaml[row] = self.meta_yaml[row].replace(str(content), str(value))
        if not str(value) in self.meta_yaml[row]:
            self.meta_yaml[row] = self.meta_yaml[row][:col] + value
        self.render()

    @property
    def package_names(self) -> List[str]:
        """List of the packages built by this recipe (including outputs)"""
        packages = [self.name]
        if "outputs" in self.meta:
            packages.extend(output['name']
                            for output in self.meta['outputs']
                            if output != self.name)
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
                raise HasSelector(self, line=lineno)
            new = re_before.sub(after, line)
            logger.debug("%i - %s", lineno, self.meta_yaml[lineno])
            logger.debug("%i + %s", lineno, new)
            self.meta_yaml[lineno] = new
            replacements += 1
        return replacements

    def reset_buildnumber(self, n: int=0):
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
        line = re.sub("number: [0-9]+", "number: "+str(n), line)
        self.meta_yaml[lineno] = line
        self.render()

    def get_deps(self, sections=None, output=True):
        return list(self.get_deps_dict(sections, output).keys())

    def get_deps_dict(self, sections=None, outputs=True):
        if not sections:
            sections = ('build', 'run', 'host')
        else:
            sections = utils.ensure_list(sections)
        check_paths = []
        for section in sections:
            check_paths.append(f'requirements/{section}')
        if outputs:
            for section in sections:
                for n in range(len(self.get('outputs', []))):
                    check_paths.append(f'outputs/{n}/requirements/{section}')
        deps = {}
        for path in check_paths:
            for n, spec in enumerate(self.get(path, [])):
                if spec is None:  # Fixme: lint this
                    continue
                dep = re.split(r'[\s<=>]', spec)[0]
                deps.setdefault(dep, []).append(f"{path}/{n}")
        return deps

    def conda_render(self,
                     bypass_env_check=True,
                     finalize=True,
                     permit_unsatisfiable_variants=False,
                     **kwargs) -> List[Tuple[MetaData, bool, bool]]:
        """Handles calling conda_build.api.render

        ``conda_build.api.render`` is fragile, loud and slow. Avoid using this
        whenever you can.

        This function will create a temporary directory, write out the
        current ``meta.yaml`` contents, redirect stdout and stderr to silence
        needless prints, ultimately call the `render` function, catching
        various exceptions and rewriting them into `CondaRenderFailure`, then
        cache the result.

        Since the ``MetaData`` objects returned expect the on-disk ``meta.yaml``
        to persist (it can get reloaded later on), clients of this function
        must **make sure to call `conda_release` once you are done** with those
        objects.

        Args:
          bypass_env_check:
             Avoids calling solver to fill in values for ``pin_compatible``
             and ``resolved_packages`` in Jinja2 expansion.
             **Changed default:** ``conda-build.api.render`` defaults to False,
             we set this to True as it is very slow.
          finalize:
             Has ``render()`` run ``finalize_metadata``, which fills in
             versions for host/run dependencies.
          permit_unsatisfiable_variants:
             Avoids raising ``UnsatisfiableError`` or
             ``DependencyNeedsBuildingError`` when determining package
             dependencies.
             **Changed default:** Set to True upstream, we set this to False
             to be informed about dependency problems.
          kwargs:
             passed on to ``conda_build.api.render``

        Raises:
          `CondaRenderfailure`: Some of the exceptions raised are rewritten
                                to simplify handling. The list will grow, but
                                is likely incomplete.
        Returns:
          List of 3-tuples each comprising the rendered MetaData and the flags
          ``needs_download`` and ``needs_render_in_env``.

        FIXME:
          Need to use **kwargs** to invalidate cache.
        """
        if self._conda_meta:
            return self._conda_meta
        self.conda_release()

        self._conda_tempdir = tempfile.TemporaryDirectory()

        with open(os.path.join(self._conda_tempdir.name, 'meta.yaml'), 'w') as tmpfile:
                tmpfile.write(self.dump())

        if self.conda_build_config:
            cbc_path = Path(self._conda_tempdir.name, "conda_build_config.yaml")
            cbc_path.write_text(self.conda_build_config)

        for script, content in self.build_scripts.items():
            script_path = Path(self._conda_tempdir.name, script)
            script_path.write_text(content)

        old_exit = sys.exit
        if isinstance(sys.exit, types.FunctionType):
            def new_exit(args=None):
                raise SystemExit(args)
            sys.exit = new_exit

        try:
            with open("/dev/null", "w") as devnull:
                with redirect_stdout(devnull), redirect_stderr(devnull):
                    self._conda_meta = conda_build.api.render(
                        self._conda_tempdir.name,
                        finalize=finalize,
                        bypass_env_check=bypass_env_check,
                        permit_unsatisfiable_variants=permit_unsatisfiable_variants,
                        **kwargs)
        except RuntimeError as exc:
            if exc.args[0].startswith("Couldn't extract raw recipe text"):
                line = self.meta_yaml[0]
                if not line.startswith('package') or line.startswith('build'):
                    raise CondaRenderFailure(self, "Must start with package or build section")
            raise
        except SystemExit as exc:
            msg = exc.args[0]
            if msg.startswith("Error: Failed to render jinja"):
                msg = '; '.join(msg.splitlines()[1:]) if '\n' in msg else msg
                raise CondaRenderFailure(self, f"Jinja2 Template Error: '{msg}'")
            raise CondaRenderFailure(
                self, f"Unknown SystemExit raised in Conda-Build Render API: '{msg}'")
        finally:
            sys.exit = old_exit
        return self._conda_meta

    def conda_release(self):
        """Releases resources acquired in `conda_render`"""
        if self._conda_meta:
            self._conda_meta = None
        if self._conda_tempdir:
            self._conda_tempdir.cleanup()
            self._conda_tempdir = None


def load_parallel_iter(recipe_folder, packages):
    recipes = list(utils.get_recipes(recipe_folder, packages))
    for recipe in utils.parallel_iter(Recipe.from_file, recipes, "Loading Recipes...",
                                      recipe_folder, return_exceptions=True):
        if isinstance(recipe, RecipeError):
            recipe.log()
        elif isinstance(recipe, Exception):
            logger.error("Could not load recipe %s", recipe)
        else:
            yield recipe

