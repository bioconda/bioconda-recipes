"""
Utility Functions and Classes

This module collects small pieces of code used throughout :py:mod:`bioconda_utils`.
"""

import asyncio
import contextlib
import datetime
import fnmatch
import glob
import logging
import os
import subprocess as sp
import sys
import shutil
import json
import queue
import warnings

from threading import Event, Thread
from pathlib import PurePath
from collections import Counter, Iterable, defaultdict, namedtuple
from itertools import product, chain, groupby, zip_longest
from functools import partial
from typing import Sequence, Collection, List, Dict, Any, Union
from multiprocessing import Pool
from multiprocessing.pool import ThreadPool

import pkg_resources
import pandas as pd
import tqdm as _tqdm
import aiohttp
import backoff
import yaml
import jinja2
from jinja2 import Environment, PackageLoader

# FIXME(upstream): For conda>=4.7.0 initialize_logging is (erroneously) called
#                  by conda.core.index.get_index which messes up our logging.
# => Prevent custom conda logging init before importing anything conda-related.
import conda.gateways.logging
conda.gateways.logging.initialize_logging = lambda: None

from conda_build import api
from conda.exports import VersionOrder

from jsonschema import validate
from colorlog import ColoredFormatter
from boltons.funcutils import FunctionBuilder


logger = logging.getLogger(__name__)


class TqdmHandler(logging.StreamHandler):
    """Tqdm aware logging StreamHandler

    Passes all log writes through tqdm to allow progress bars and log
    messages to coexist without clobbering terminal
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
         # initialise internal tqdm lock so that we can use tqdm.write
        _tqdm.tqdm(disable=True, total=0)
    def emit(self, record):
        _tqdm.tqdm.write(self.format(record))


def tqdm(*args, **kwargs):
    """Wrapper around TQDM handling disable

    Logging is disabled if:

    - ``TERM`` is set to ``dumb``
    - ``CIRCLECI`` is set to ``true``
    - the effective log level of the is lower than set via ``loglevel``

    Args:
      loglevel: logging loglevel (the number, so logging.INFO)
      logger: local logger (in case it has different effective log level)
    """
    term_ok = (sys.stderr.isatty()
               and os.environ.get("TERM", "") != "dumb"
               and os.environ.get("CIRCLECI", "") != "true")
    loglevel_ok = (kwargs.get('logger', logger).getEffectiveLevel()
                   <= kwargs.get('loglevel', logging.INFO))
    kwargs['disable'] = not (term_ok and loglevel_ok)
    return _tqdm.tqdm(*args, **kwargs)



def ensure_list(obj):
    """Wraps **obj** in a list if necessary

    >>> ensure_list("one")
    ["one"]
    >>> ensure_list(["one", "two"])
    ["one", "two"]
    """
    if isinstance(obj, Sequence) and not isinstance(obj, str):
        return obj
    return [obj]


def wraps(func):
    """Custom wraps() function for decorators

    This one differs from functiools.wraps and boltons.funcutils.wraps in
    that it allows *adding* keyword arguments to the function signature.

    >>> def decorator(func):
    >>>   @wraps(func)
    >>>   def wrapper(*args, extra_param=None, **kwargs):
    >>>      print("Called with extra_param=%s" % extra_param)
    >>>      func(*args, **kwargs)
    >>>   return wrapper
    >>>
    >>> @decorator()
    >>> def test(arg1, arg2, arg3='default'):
    >>>     pass
    >>>
    >>> test('val1', 'val2', extra_param='xyz')
    """

    fb = FunctionBuilder.from_func(func)
    def wrapper_wrapper(wrapper_func):
        fb_wrapper = FunctionBuilder.from_func(wrapper_func)
        fb.kwonlyargs += fb_wrapper.kwonlyargs
        fb.kwonlydefaults.update(fb_wrapper.kwonlydefaults)
        fb.body = 'return _call(%s)' % fb.get_invocation_str()
        execdict = dict(_call=wrapper_func, _func=func)
        fully_wrapped = fb.get_func(execdict)
        fully_wrapped.__wrapped__ = func
        return fully_wrapped

    return wrapper_wrapper


class LogFuncFilter:
    """Logging filter capping the number of messages emitted from given function

    Arguments:
      func: The function for which to filter log messages
      trunc_msg: The message to emit when logging is truncated, to inform user that
                 messages will from now on be hidden.
      max_lines: Max number of log messages to allow to pass
      consectuctive: If try, filter applies to consectutive messages and resets
                     if a message from a different source is encountered.

    Fixme:
      The implementation  assumes that **func** uses a logger initialized with
      ``getLogger(__name__)``.
    """
    def __init__(self, func, trunc_msg: str = None, max_lines: int = 0,
                 consecutive: bool = True) -> None:
        self.func = func
        self.max_lines = max_lines + 1
        self.cur_max_lines = max_lines + 1
        self.consecutive = consecutive
        self.trunc_msg = trunc_msg

    def filter(self, record: logging.LogRecord) -> bool:
        if record.name == self.func.__module__ and record.funcName == self.func.__name__:
            if self.cur_max_lines > 1:
                self.cur_max_lines -= 1
                return True
            if self.cur_max_lines == 1 and self.trunc_msg:
                self.cur_max_lines -= 1
                record.msg = self.trunc_msg
                return True
            return False
        if self.consecutive:
            self.cur_max_lines = self.max_lines
        return True


class LoggingSourceRenameFilter:
    """Logging filter for abbreviating module name in logs

    Maps ``bioconda_utils`` to ``BIOCONDA`` and for everything else
    to just the top level package uppercased.
    """
    def filter(self, record: logging.LogRecord) -> bool:
        if record.name.startswith("bioconda_utils"):
            record.name = "BIOCONDA"
        else:
            record.name = record.name.split('.')[0].upper()
        return True


def setup_logger(name: str = 'bioconda_utils', loglevel: Union[str, int] = logging.INFO,
                 logfile: str = None, logfile_level: Union[str, int] = logging.DEBUG,
                 log_command_max_lines = None,
                 prefix: str = "BIOCONDA ",
                 msgfmt: str = ("%(asctime)s "
                                "%(log_color)s%(name)s %(levelname)s%(reset)s "
                                "%(message)s"),
                 datefmt: str ="%H:%M:%S") -> logging.Logger:
    """Set up logging for bioconda-utils

    Args:
      name: Module name for which to get a logger (``__name__``)
      loglevel: Log level, can be name or int level
      logfile: File to log to as well
      logfile_level: Log level for file logging
      prefix: Prefix to add to our log messages
      msgfmt: Format for messages
      datefmt: Format for dates

    Returns:
      A new logger
    """
    new_logger = logging.getLogger(name)
    root_logger = logging.getLogger()

    if logfile:
        if isinstance(logfile_level, str):
            logfile_level = getattr(logging, logfile_level.upper())
        log_file_handler = logging.FileHandler(logfile)
        log_file_handler.setLevel(logfile_level)
        log_file_formatter = logging.Formatter(
            msgfmt.replace("%(log_color)s", "").replace("%(reset)s", "").format(prefix=prefix),
            datefmt=None,
        )
        log_file_handler.setFormatter(log_file_formatter)
        root_logger.addHandler(log_file_handler)
    else:
        logfile_level = logging.FATAL

    if isinstance(loglevel, str):
        loglevel = getattr(logging, loglevel.upper())

    # Base logger is set to the lowest of console or file logging
    root_logger.setLevel(min(loglevel, logfile_level))

    # Console logging is passed through TqdmHandler so that the progress bar does not
    # get broken by log lines emitted.
    log_stream_handler = TqdmHandler()
    if loglevel:
        log_stream_handler.setLevel(loglevel)

    log_stream_handler.setFormatter(ColoredFormatter(
        msgfmt.format(prefix=prefix),
        datefmt=datefmt,
        reset=True,
        log_colors={
            'DEBUG': 'cyan',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red',
        }))
    log_stream_handler.addFilter(LoggingSourceRenameFilter())
    root_logger.addHandler(log_stream_handler)

    # Add filter for `utils.run` to truncate after n lines emitted.
    # We do this here rather than in `utils.run` so that it can be configured
    # from the CLI more easily
    if log_command_max_lines is not None:
        log_filter = LogFuncFilter(run, "Command output truncated", log_command_max_lines)
        log_stream_handler.addFilter(log_filter)

    return new_logger


def ellipsize_recipes(recipes: Collection[str], recipe_folder: str,
                      n: int = 5, m: int = 50) -> str:
    """Logging helper showing recipe list

    Args:
      recipes: List of recipes
      recipe_folder: Folder name to strip from recipes.
      n: Show at most this number of recipes, with "..." if more are found.
      m: Don't show anything if more recipes than this
         (pointless to show first 5 of 5000)
    Returns:
      A string like " (htslib, samtools, ...)" or ""
    """
    if not recipes or len(recipes) > m:
        return ""
    if len(recipes) > n:
        if not isinstance(recipes, Sequence):
            recipes = list(recipes)
        recipes = recipes[:n]
        append = ", ..."
    else:
        append = ""
    return ' ('+', '.join(recipe.lstrip(recipe_folder).lstrip('/')
                     for recipe in recipes) + append + ')'


class JinjaSilentUndefined(jinja2.Undefined):
    def _fail_with_undefined_error(self, *args, **kwargs):
        return ""

    __add__ = __radd__ = __mul__ = __rmul__ = __div__ = __rdiv__ = \
        __truediv__ = __rtruediv__ = __floordiv__ = __rfloordiv__ = \
        __mod__ = __rmod__ = __pos__ = __neg__ = __call__ = \
        __getitem__ = __lt__ = __le__ = __gt__ = __ge__ = __int__ = \
        __float__ = __complex__ = __pow__ = __rpow__ = \
        _fail_with_undefined_error


jinja = Environment(
    loader=PackageLoader('bioconda_utils', 'templates'),
    trim_blocks=True,
    lstrip_blocks=True
)


jinja_silent_undef = Environment(
    undefined=JinjaSilentUndefined
)


# Patterns of allowed environment variables that are allowed to be passed to
# conda-build.
ENV_VAR_WHITELIST = [
    'PATH',
    'LC_*',
    'LANG',
    'MACOSX_DEPLOYMENT_TARGET',
    'HTTPS_PROXY','HTTP_PROXY', 'https_proxy', 'http_proxy',
]

# Of those that make it through the whitelist, remove these specific ones
ENV_VAR_BLACKLIST = [
]

# Of those, also remove these when we're running in a docker container
ENV_VAR_DOCKER_BLACKLIST = [
    'PATH',
]


def get_free_space():
    """Return free space in MB on disk"""
    s = os.statvfs(os.getcwd())
    return s.f_frsize * s.f_bavail / (1024 ** 2)


def allowed_env_var(s, docker=False):
    for pattern in ENV_VAR_WHITELIST:
        if fnmatch.fnmatch(s, pattern):
            for bpattern in ENV_VAR_BLACKLIST:
                if fnmatch.fnmatch(s, bpattern):
                    return False
            if docker:
                for dpattern in ENV_VAR_DOCKER_BLACKLIST:
                    if fnmatch.fnmatch(s, dpattern):
                        return False
            return True


def bin_for(name='conda'):
    if 'CONDA_ROOT' in os.environ:
        return os.path.join(os.environ['CONDA_ROOT'], 'bin', name)
    return name


@contextlib.contextmanager
def temp_env(env):
    """
    Context manager to temporarily set os.environ.

    Used to send values in **env** to processes that only read the os.environ,
    for example when filling in meta.yaml with jinja2 template variables.

    All values are converted to string before sending to os.environ
    """
    env = dict(env)
    orig = os.environ.copy()
    _env = {k: str(v) for k, v in env.items()}
    os.environ.update(_env)
    try:
        yield
    finally:
        os.environ.clear()
        os.environ.update(orig)


@contextlib.contextmanager
def sandboxed_env(env):
    """
    Context manager to temporarily set os.environ, only allowing env vars from
    the existing `os.environ` or the provided **env** that match
    ENV_VAR_WHITELIST globs.
    """
    env = dict(env)
    orig = os.environ.copy()

    _env = {k: v for k, v in orig.items() if allowed_env_var(k)}
    _env.update({k: str(v) for k, v in env.items() if allowed_env_var(k)})

    os.environ = _env

    try:
        yield
    finally:
        os.environ.clear()
        os.environ.update(orig)


def load_all_meta(recipe, config=None, finalize=True):
    """
    For each environment, yield the rendered meta.yaml.

    Parameters
    ----------
    finalize : bool
        If True, do a full conda-build render. Determines exact package builds
        of build/host dependencies. It involves costly dependency resolution
        via conda and also download of those packages (to inspect possible
        run_exports). For fast-running tasks like linting, set to False.
    """
    if config is None:
        config = load_conda_build_config()
    # `bypass_env_check=True` prevents evaluating (=environment solving) the
    # package versions used for `pin_compatible` and the like.
    # To avoid adding a separate `bypass_env_check` alongside every `finalize`
    # parameter, just assume we always want to bypass if `finalize is True`.
    bypass_env_check = (not finalize)
    return [meta for (meta, _, _) in api.render(recipe,
                                                config=config,
                                                finalize=finalize,
                                                bypass_env_check=bypass_env_check,
                                                )]



def load_meta_fast(recipe: str, env=None):
    """
    Given a package name, find the current meta.yaml file, parse it, and return
    the dict.

    Args:
      recipe: Path to recipe (directory containing the meta.yaml file)
      env: Optional variables to expand

    Returns:
      Tuple of original recipe string and rendered dict
    """
    if not env:
        env = {}

    try:
        pth = os.path.join(recipe, 'meta.yaml')
        template = jinja_silent_undef.from_string(open(pth, 'r', encoding='utf-8').read())
        meta = yaml.safe_load(template.render(env))
        return (meta, recipe)
    except Exception:
        raise ValueError('Problem inspecting {0}'.format(recipe))


def load_conda_build_config(platform=None, trim_skip=True):
    """
    Load conda build config while considering global pinnings from conda-forge.
    """
    config = api.Config(
        no_download_source=True,
        set_build_id=False)

    # get environment root
    env_root = PurePath(shutil.which("bioconda-utils")).parents[1]
    # set path to pinnings from conda forge package
    config.exclusive_config_files = [
        os.path.join(env_root, "conda_build_config.yaml"),
        os.path.join(
            os.path.dirname(__file__),
            'bioconda_utils-conda_build_config.yaml'),
    ]
    for cfg in chain(config.exclusive_config_files, config.variant_config_files or []):
        assert os.path.exists(cfg), ('error: {0} does not exist'.format(cfg))
    if platform:
        config.platform = platform
    config.trim_skip = trim_skip
    return config


CondaBuildConfigFile = namedtuple('CondaBuildConfigFile', (
    'arg',  # either '-e' or '-m'
    'path',
))


def get_conda_build_config_files(config=None):
    if config is None:
        config = load_conda_build_config()
    # TODO: open PR upstream for conda-build to support multiple exclusive_config_files
    for file_path in (config.exclusive_config_files or []):
        yield CondaBuildConfigFile('-e', file_path)
    for file_path in (config.variant_config_files or []):
        yield CondaBuildConfigFile('-m', file_path)


def load_first_metadata(recipe, config=None, finalize=True):
    """
    Returns just the first of possibly many metadata files. Used for when you
    need to do things like check a package name or version number (which are
    not expected to change between variants).

    If the recipe will be skipped, then returns None

    Parameters
    ----------
    finalize : bool
        If True, do a full conda-build render. Determines exact package builds
        of build/host dependencies. It involves costly dependency resolution
        via conda and also download of those packages (to inspect possible
        run_exports). For fast-running tasks like linting, set to False.
    """
    metas = load_all_meta(recipe, config, finalize=finalize)
    if len(metas) > 0:
        return metas[0]


@contextlib.contextmanager
def temp_os(platform):
    """
    Context manager to temporarily set sys.platform.
    """
    original = sys.platform
    sys.platform = platform
    try:
        yield
    finally:
        sys.platform = original


def run(cmds: List[str], env: Dict[str, str]=None, mask: List[str]=None, live: bool=True,
        mylogger: logging.Logger=logger, loglevel: int=logging.INFO,
        **kwargs: Dict[Any, Any]) -> sp.CompletedProcess:
    """
    Run a command (with logging, masking, etc)

    - Explicitly decodes stdout to avoid UnicodeDecodeErrors that can occur when
      using the ``universal_newlines=True`` argument in the standard
      subprocess.run.
    - Masks secrets
    - Passed live output to `logging`

    Arguments:
      cmd: List of command and arguments
      env: Optional environment for command
      mask: List of terms to mask (secrets)
      live: Whether output should be sent to log
      kwargs: Additional arguments to `subprocess.Popen`

    Returns:
      CompletedProcess object

    Raises:
      subprocess.CalledProcessError if the process failed
      FileNotFoundError if the command could not be found
    """
    logq = queue.Queue()

    def pushqueue(out, pipe):
        """Reads from a pipe and pushes into a queue, pushing "None" to
        indicate closed pipe"""
        for line in iter(pipe.readline, b''):
            out.put((pipe, line))
        out.put(None)  # End-of-data-token

    def do_mask(arg: str) -> str:
        """Masks secrets in **arg**"""
        if mask is None:
            # caller has not considered masking, hide the entire command
            # for security reasons
            return '<hidden>'
        if mask is False:
            # masking has been deactivated
            return arg
        for mitem in mask:
            arg = arg.replace(mitem, '<hidden>')
        return arg

    mylogger.log(loglevel, "(COMMAND) %s", ' '.join(do_mask(arg) for arg in cmds))

    # bufsize=4 result of manual experimentation. Changing it can
    # drop performance drastically.
    with sp.Popen(cmds, stdout=sp.PIPE, stderr=sp.PIPE,
                  close_fds=True, env=env, bufsize=4, **kwargs) as proc:
        # Start threads reading stdout/stderr and pushing it into queue q
        out_thread = Thread(target=pushqueue, args=(logq, proc.stdout))
        err_thread = Thread(target=pushqueue, args=(logq, proc.stderr))
        out_thread.daemon = True  # Do not wait for these threads to terminate
        err_thread.daemon = True
        out_thread.start()
        err_thread.start()

        output_lines = []
        try:
            for _ in range(2):  # Run until we've got both `None` tokens
                for pipe, line in iter(logq.get, None):
                    line = do_mask(line.decode(errors='replace').rstrip())
                    output_lines.append(line)
                    if live:
                        if pipe == proc.stdout:
                            prefix = "OUT"
                        else:
                            prefix = "ERR"
                        mylogger.log(loglevel, "(%s) %s", prefix, line)
        except Exception:
            proc.kill()
            proc.wait()
            raise

        output = "\n".join(output_lines)
        if isinstance(cmds, str):
            masked_cmds = do_mask(cmds)
        else:
            masked_cmds = [do_mask(c) for c in cmds]

        if proc.poll() is None:
            mylogger.log(loglevel, 'Command closed STDOUT/STDERR but is still running')
            waitfor = 30
            waittimes = 5
            for attempt in range(waittimes):
                mylogger.log(loglevel, "Waiting %s seconds (%i/%i)", waitfor, attempt+1, waittimes)
                try:
                    proc.wait(timeout=waitfor)
                    break;
                except sp.TimeoutExpired:
                    pass
            else:
                mylogger.log(loglevel, "Terminating process")
                proc.kill()
                proc.wait()
        returncode = proc.poll()

        if returncode:
            logger.error('COMMAND FAILED (exited with %s): %s', returncode, ' '.join(masked_cmds))
            if not live:
                logger.error('STDOUT+STDERR:\n%s', output)
            raise sp.CalledProcessError(returncode, masked_cmds, output=output)

        return sp.CompletedProcess(returncode, masked_cmds, output)


def envstr(env):
    env = dict(env)
    return ';'.join(['='.join([i, str(j)]) for i, j in sorted(env.items())])


def flatten_dict(dict):
    for key, values in dict.items():
        if isinstance(values, str) or not isinstance(values, Iterable):
            values = [values]
        yield [(key, value) for value in values]


class EnvMatrix:
    """
    Intended to be initialized with a YAML file and iterated over to yield all
    combinations of environments.

    YAML file has the following format::

        CONDA_PY:
          - "2.7"
          - "3.5"
        CONDA_BOOST: "1.60"
        CONDA_PERL: "5.22.0"
        CONDA_NPY: "110"
        CONDA_NCURSES: "5.9"
        CONDA_GSL: "1.16"

    """

    def __init__(self, env):
        """
        Parameters
        ----------

        env : str or dict
            If str, assume it's a path to a YAML-format filename and load it
            into a dict. If a dict is provided, use it directly.
        """
        if isinstance(env, str):
            with open(env) as f:
                self.env = yaml.safe_load(f)
        else:
            self.env = env
        for key, val in self.env.items():
            if key != "CONDA_PY" and not isinstance(val, str):
                raise ValueError(
                    "All versions except CONDA_PY must be strings.")

    def __iter__(self):
        """
        Given the YAML::

            CONDA_PY:
              - "2.7"
              - "3.5"
            CONDA_BOOST: "1.60"
            CONDA_NPY: "110"

        We get the following sets of env vars::

          [('CONDA_BOOST', '1.60'), ('CONDA_PY', '2.7'), ('CONDA_NPY', '110')]
          [('CONDA_BOOST', '1.60'), ('CONDA_PY', '3.5'), ('CONDA_NPY', '110')]

        A copy of the entire os.environ dict is updated and yielded for each of
        these sets.
        """
        for env in product(*flatten_dict(self.env)):
            yield env


def get_deps(recipe=None, build=True):
    """
    Generator of dependencies for a single recipe

    Only names (not versions) of dependencies are yielded.

    If the variant/version matrix yields multiple instances of the metadata,
    the union of these dependencies is returned.

    Parameters
    ----------
    recipe : str or MetaData
        If string, it is a path to the recipe; otherwise assume it is a parsed
        conda_build.metadata.MetaData instance.

    build : bool
        If True yield build dependencies, if False yield run dependencies.
    """
    if recipe is not None:
        assert isinstance(recipe, str)
        metadata = load_all_meta(recipe, finalize=False)
    elif meta is not None:
        metadata = [meta]
    else:
        raise ValueError("Either meta or recipe has to be specified.")

    all_deps = set()
    for meta in metadata:
        if build:
            deps = meta.get_value('requirements/build', [])
        else:
            deps = meta.get_value('requirements/run', [])
        all_deps.update(dep.split()[0] for dep in deps)
    return all_deps


_max_threads = 1


def set_max_threads(n):
    global _max_threads
    _max_threads = n


def threads_to_use():
    """Returns the number of cores we are allowed to run on"""
    if hasattr(os, 'sched_getaffinity'):
        cores = len(os.sched_getaffinity(0))
    else:
        cores = os.cpu_count()
    return min(_max_threads, cores)


def parallel_iter(func, items, desc, *args, **kwargs):
    pfunc = partial(func, *args, **kwargs)
    with Pool(threads_to_use()) as pool:
        yield from tqdm(
            pool.imap_unordered(pfunc, items),
            desc=desc,
            total=len(items)
        )




def get_recipes(recipe_folder, package="*", exclude=None):
    """
    Generator of recipes.

    Finds (possibly nested) directories containing a ``meta.yaml`` file.

    Parameters
    ----------
    recipe_folder : str
        Top-level dir of the recipes

    package : str or iterable
        Pattern or patterns to restrict the results.
    """
    if isinstance(package, str):
        package = [package]
    if isinstance(exclude, str):
        exclude = [exclude]
    if exclude is None:
        exclude = []
    for p in package:
        logger.debug("get_recipes(%s, package='%s'): %s",
                     recipe_folder, package, p)
        path = os.path.join(recipe_folder, p)
        for new_dir in glob.glob(path):
            meta_yaml_found = False
            for dir_path, dir_names, file_names in os.walk(new_dir):
                if any(fnmatch.fnmatch(dir_path[len(recipe_folder):], pat) for pat in exclude):
                    continue
                if "meta.yaml" in file_names:
                    meta_yaml_found = True
                    yield dir_path
            if not meta_yaml_found and os.path.isdir(new_dir):
                logger.warn(
                    "No meta.yaml found in %s."
                    " If you want to ignore this directory, add it to the blacklist.",
                    new_dir
                )
                yield new_dir


def get_latest_recipes(recipe_folder, config, package="*"):
    """
    Generator of recipes.

    Finds (possibly nested) directories containing a ``meta.yaml`` file and returns
    the latest version of each recipe.

    Parameters
    ----------
    recipe_folder : str
        Top-level dir of the recipes

    config : dict or filename

    package : str or iterable
        Pattern or patterns to restrict the results.
    """

    def toplevel(x):
        return x.replace(
            recipe_folder, '').strip(os.path.sep).split(os.path.sep)[0]

    config = load_config(config)
    recipes = sorted(get_recipes(recipe_folder, package), key=toplevel)

    for package, group in groupby(recipes, key=toplevel):
        group = list(group)
        if len(group) == 1:
            yield group[0]
        else:
            def get_version(p):
                meta_path = os.path.join(p, 'meta.yaml')
                meta = load_first_metadata(meta_path, finalize=False)
                version = meta.get_value('package/version')
                return VersionOrder(version)
            sorted_versions = sorted(group, key=get_version)
            if sorted_versions:
                yield sorted_versions[-1]


class DivergentBuildsError(Exception):
    pass


def _string_or_float_to_integer_python(s):
    """
    conda-build 2.0.4 expects CONDA_PY values to be integers (e.g., 27, 35) but
    older versions were OK with strings or even floats.

    To avoid editing existing config files, we support those values here.
    """

    try:
        s = float(s)
        if s < 10:  # it'll be a looong time before we hit Python 10.0
            s = int(s * 10)
        else:
            s = int(s)
    except ValueError:
        raise ValueError("{} is an unrecognized Python version".format(s))
    return s


def built_package_paths(recipe):
    """
    Returns the path to which a recipe would be built.

    Does not necessarily exist; equivalent to ``conda build --output recipename``
    but without the subprocess.
    """
    config = load_conda_build_config()
    # NB: Setting bypass_env_check disables ``pin_compatible`` parsing, which
    #     these days does not change the package build string, so should be fine.
    paths = api.get_output_file_paths(recipe, config=config, bypass_env_check=True)
    return paths


def last_commit_to_master():
    """
    Identifies the day of the last commit to master branch.
    """
    if not shutil.which('git'):
        raise ValueError("git not found")
    p = sp.run(
        'git log master --date=iso | grep "^Date:" | head -n1',
        shell=True, stdout=sp.PIPE, check=True
    )
    date = datetime.datetime.strptime(
        p.stdout[:-1].decode().split()[1],
        '%Y-%m-%d')
    return date


def file_from_commit(commit, filename):
    """
    Returns the contents of a file at a particular commit as a string.

    Parameters
    ----------
    commit : commit-like string

    filename : str
    """
    if commit == 'HEAD':
        return open(filename).read()

    p = run(['git', 'show', '{0}:{1}'.format(commit, filename)], mask=False,
            loglevel=0)
    return str(p.stdout)


def newly_unblacklisted(config_file, recipe_folder, git_range):
    """
    Returns the set of recipes that were blacklisted in master branch but have
    since been removed from the blacklist. Considers the contents of all
    blacklists in the current config file and all blacklists in the same config
    file in master branch.

    Parameters
    ----------

    config_file : str
        Needs filename (and not dict) because we check what the contents of the
        config file were in the master branch.

    recipe_folder : str
        Path to recipe dir, needed by get_blacklist

    git_range : str or list
        If str or single-item list. If ``'HEAD'`` or ``['HEAD']`` or ``['master',
        'HEAD']``, compares the current changes to master. If other commits are
        specified, then use those commits directly via ``git show``.
    """

    # 'HEAD' becomes ['HEAD'] and then ['master', 'HEAD'].
    # ['HEAD'] becomes ['master', 'HEAD']
    # ['HEAD~~', 'HEAD'] stays the same
    if isinstance(git_range, str):
        git_range = [git_range]

    if len(git_range) == 1:
        git_range = ['master', git_range[0]]

    # Get the set of previously blacklisted recipes by reading the original
    # config file and then all the original blacklists it had listed
    previous = set()
    orig_config = file_from_commit(git_range[0], config_file)
    for bl in yaml.safe_load(orig_config)['blacklists']:
        with open('.tmp.blacklist', 'w', encoding='utf8') as fout:
            fout.write(file_from_commit(git_range[0], bl))
        previous.update(get_blacklist({'blacklists': '.tmp.blacklist'}, recipe_folder))
        os.unlink('.tmp.blacklist')

    current = get_blacklist(
        yaml.safe_load(file_from_commit(git_range[1], config_file)),
        recipe_folder)
    results = previous.difference(current)
    logger.info('Recipes newly unblacklisted:\n%s', '\n'.join(list(results)))
    return results


def changed_since_master(recipe_folder):
    """
    Return filenames changed since master branch.

    Note that this uses ``origin``, so if you are working on a fork of the main
    repo and have added the main repo as ``upstream``, then you'll have to do
    a ``git checkout master && git pull upstream master`` to update your fork.
    """
    p = run(['git', 'fetch', 'origin', 'master'], mask=False, loglevel=0)
    p = run(['git', 'diff', 'FETCH_HEAD', '--name-only'], mask=False, loglevel=0)
    return [
        os.path.dirname(os.path.relpath(i, recipe_folder))
        for i in p.stdout.splitlines(False)
    ]


def _load_platform_metas(recipe, finalize=True):
    # check if package is noarch, if so, build only on linux
    # with temp_os, we can fool the MetaData if needed.
    platform = os.environ.get('OSTYPE', sys.platform)
    if platform.startswith("darwin"):
        platform = 'osx'
    elif platform == "linux-gnu":
        platform = "linux"

    config = load_conda_build_config(platform=platform)
    return platform, load_all_meta(recipe, config=config, finalize=finalize)


def _meta_subdir(meta):
    # logic extracted from conda_build.variants.bldpkg_path
    return 'noarch' if meta.noarch or meta.noarch_python else meta.config.host_subdir



def check_recipe_skippable(recipe, check_channels):
    """
    Return True if the same number of builds (per subdir) defined by the recipe
    are already in channel_packages.
    """
    platform, metas = _load_platform_metas(recipe, finalize=False)
    packages =  set(
        (meta.name(), meta.version(), int(meta.build_number() or 0))
        for meta in metas
    )
    r = RepoData()
    num_existing_pkg_builds = Counter(
        (name, version, build_number, subdir)
        for name, version, build_number in packages
        for subdir in r.get_package_data("subdir", name=name, version=version,
                                         build_number=build_number,
                                         channels=check_channels, native=True)
    )
    if num_existing_pkg_builds == Counter():
        # No packages with same version + build num in channels: no need to skip
        return False
    num_new_pkg_builds = Counter(
        (meta.name(), meta.version(), int(meta.build_number() or 0), _meta_subdir(meta))
        for meta in metas
    )
    return num_new_pkg_builds == num_existing_pkg_builds


def _filter_existing_packages(metas, check_channels):
    new_metas = []  # MetaData instances of packages not yet in channel
    existing_metas = []  # MetaData instances of packages already in channel
    divergent_builds = set()  # set of Dist (i.e., name-version-build) strings

    key_build_meta = defaultdict(dict)
    for meta in metas:
        pkg_key = (meta.name(), meta.version(), int(meta.build_number() or 0))
        pkg_build = (_meta_subdir(meta), meta.build_id())
        key_build_meta[pkg_key][pkg_build] = meta

    r = RepoData()
    for pkg_key, build_meta in key_build_meta.items():
        existing_pkg_builds = set(r.get_package_data(['subdir', 'build'],
                                                     name=pkg_key[0],
                                                     version=pkg_key[1],
                                                     build_number=pkg_key[2],
                                                     channels=check_channels,
                                                     native=True))
        for pkg_build, meta in build_meta.items():
            if pkg_build not in existing_pkg_builds:
                new_metas.append(meta)
            else:
                existing_metas.append(meta)
        for divergent_build in (existing_pkg_builds - set(build_meta.keys())):
            divergent_builds.add(
                '-'.join((pkg_key[0], pkg_key[1], divergent_build[1])))
    return new_metas, existing_metas, divergent_builds


def get_package_paths(recipe, check_channels, force=False):
    if not force:
        if check_recipe_skippable(recipe, check_channels):
            # NB: If we skip early here, we don't detect possible divergent builds.
            logger.info(
                'FILTER: not building recipe %s because '
                'the same number of builds are in channel(s) and it is not forced.',
                recipe)
            return []
    platform, metas = _load_platform_metas(recipe, finalize=True)

    # The recipe likely defined skip: True
    if not metas:
        return []

    # If on CI, handle noarch.
    if os.environ.get('CI', None) == 'true':
        first_meta = metas[0]
        if first_meta.get_value('build/noarch'):
            if platform != 'linux':
                logger.debug('FILTER: only building %s on '
                             'linux because it defines noarch.',
                             recipe)
                return []

    new_metas, existing_metas, divergent_builds = (
        _filter_existing_packages(metas, check_channels))

    if divergent_builds:
        raise DivergentBuildsError(*sorted(divergent_builds))

    for meta in existing_metas:
        logger.info(
            'FILTER: not building %s because '
            'it is in channel(s) and it is not forced.', meta.pkg_fn())
    # yield all pkgs that do not yet exist
    if force:
        build_metas = new_metas + existing_metas
    else:
        build_metas = new_metas
    return list(chain.from_iterable(
        api.get_output_file_paths(meta) for meta in build_metas))


def get_blacklist(config: Dict[str, Any], recipe_folder: str) -> set:
    "Return list of recipes to skip from blacklists"
    blacklist = set()
    for p in config.get('blacklists', []):
        blacklist.update(
            [
                os.path.relpath(i.strip(), recipe_folder)
                for i in open(p, encoding='utf8')
                if not i.startswith('#') and i.strip()
            ]
        )
    return blacklist


def validate_config(config):
    """
    Validate config against schema

    Parameters
    ----------
    config : str or dict
        If str, assume it's a path to YAML file and load it. If dict, use it
        directly.
    """
    if not isinstance(config, dict):
        config = yaml.safe_load(open(config))
    fn = pkg_resources.resource_filename(
        'bioconda_utils', 'config.schema.yaml'
    )
    schema = yaml.safe_load(open(fn))
    validate(config, schema)


def load_config(path):
    """
    Parses config file, building paths to relevant blacklists

    Parameters
    ----------
    path : str
        Path to YAML config file
    """
    validate_config(path)

    if isinstance(path, dict):
        def relpath(p):
            return p
        config = path
    else:
        def relpath(p):
            return os.path.join(os.path.dirname(path), p)
        config = yaml.safe_load(open(path))

    def get_list(key):
        # always return empty list, also if NoneType is defined in yaml
        value = config.get(key)
        if value is None:
            return []
        return value

    default_config = {
        'blacklists': [],
        'channels': ['conda-forge', 'bioconda', 'defaults'],
        'requirements': None,
        'upload_channel': 'bioconda'
    }
    if 'blacklists' in config:
        config['blacklists'] = [relpath(p) for p in get_list('blacklists')]
    if 'channels' in config:
        config['channels'] = get_list('channels')

    default_config.update(config)

    # register config object in RepoData
    RepoData.register_config(default_config)

    return default_config


class BiocondaUtilsWarning(UserWarning):
    pass


class Progress:
    def __init__(self):
        self.thread = Thread(target=self.progress)
        self.stop = Event()

    def progress(self):
        while not self.stop.wait(60):
            print(".", end="")
            sys.stdout.flush()
        print("")

    def __enter__(self):
        self.thread.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop.set()
        self.thread.join()


class AsyncRequests:
    """Download a bunch of files in parallel

    This is not really a class, more a name space encapsulating a bunch of calls.
    """
    #: Identify ourselves
    USER_AGENT = "bioconda/bioconda-utils"
    #: Max connections to each server
    CONNECTIONS_PER_HOST = 4

    @classmethod
    def fetch(cls, urls, descs, cb, datas):
        """Fetch data from URLs.

        This will use asyncio to manage a pool of connections at once, speeding
        up download as compared to iterative use of ``requests`` significantly.
        It will also retry on non-permanent HTTP error codes (i.e. 429, 502,
        503 and 504).

        Args:
          urls: List of URLS
          descs: Matching list of descriptions (for progress display)
          cb: As each download is completed, data is passed through this function.
              Use to e.g. offload json parsing into download loop.
        """
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)

        if loop.is_running():
            logger.warning("Running AsyncRequests.fetch from within running loop")
            # Workaround the fact that asyncio's loop is marked as not-reentrant
            # (it is apparently easy to patch, but not desired by the devs,
            with ThreadPool(1) as pool:
                res = pool.apply(cls.fetch, (urls, descs, cb, datas))
            return res

        task = asyncio.ensure_future(cls.async_fetch(urls, descs, cb, datas))

        try:
            loop.run_until_complete(task)
        except KeyboardInterrupt:
            task.cancel()
            loop.run_forever()
            task.exception()

        return task.result()

    @classmethod
    async def async_fetch(cls, urls, descs=None, cb=None, datas=None, fds=None):
        if descs is None:
            descs = []
        if datas is None:
            datas = []
        if fds is None:
            fds = []
        conn = aiohttp.TCPConnector(limit_per_host=cls.CONNECTIONS_PER_HOST)
        async with aiohttp.ClientSession(
                connector=conn,
                headers={'User-Agent': cls.USER_AGENT}
        ) as session:
            coros = [
                asyncio.ensure_future(cls._async_fetch_one(session, url, desc, cb, data, fd))
                for url, desc, data, fd in zip_longest(urls, descs, datas, fds)
            ]
            with tqdm(asyncio.as_completed(coros),
                      total=len(coros),
                      desc="Downloading", unit="files") as t:
                result = [await coro for coro in t]
        return result

    @staticmethod
    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def _async_fetch_one(session, url, desc, cb=None, data=None, fd=None):
        result = []
        async with session.get(url, timeout=None) as resp:
            resp.raise_for_status()
            size = int(resp.headers.get("Content-Length", 0))
            with tqdm(total=size, unit='B', unit_scale=True, unit_divisor=1024,
                      desc=desc, miniters=1,
                      disable=logger.getEffectiveLevel() > logging.INFO
            ) as progress:
                while True:
                    block = await resp.content.read(1024*16)
                    if not block:
                        break
                    progress.update(len(block))
                    if fd:
                        fd.write(block)
                    else:
                        result.append(block)
        if cb:
            return cb(b"".join(result), data)
        else:
            return b"".join(result)


class RepoData:
    """Singleton providing access to package directory on anaconda cloud

    If the first call provides a filename as **cache** argument, the
    file is used to cache the directory in CSV format.

    Data structure:

    Each **channel** hosted at anaconda cloud comprises a number of
    **subdirs** in which the individual package files reside. The
    **subdirs** can be one of **noarch**, **osx-64** and **linux-64**
    for Bioconda. (Technically ``(noarch|(linux|osx|win)-(64|32))``
    appears to be the schema).

    For **channel/subdir** (aka **channel/platform**) combination, a
    **repodata.json** contains a **package** key describing each
    package file with at least the following information:

    name: Package name (lowercase, alphanumeric + dash)

    version: Version (no dash, PEP440)

    build_number: Non negative integer indicating packaging revisions

    build: String comprising hash of pinned dependencies and build
      number. Used to distinguish different builds of the same
      package/version combination.

    depends: Runtime requirements for package as list of strings. We
      do not currently load this.

    arch: Architecture key (x86_64). Not used by conda and not loaded
      here.

    platform: Platform of package (osx, linux, noarch). Optional
      upstream, not used by conda. We generate this from the subdir
      information to have it available.


    Repodata versions:

    The version is indicated by the key **repodata_version**, with
    absence of that key indication version 0.

    In version 0, the **info** key contains the **subdir**,
    **platform**, **arch**, **default_python_version** and
    **default_numpy_version** keys. In version 1 it only contains the
    **subdir** key.

    In version 1, a key **removed** was added, listing packages
    removed from the repository.

    """

    REPODATA_URL = 'https://conda.anaconda.org/{channel}/{subdir}/repodata.json'
    REPODATA_LABELED_URL = 'https://conda.anaconda.org/{channel}/label/{label}/{subdir}/repodata.json'
    REPODATA_DEFAULTS_URL = 'https://repo.anaconda.com/pkgs/main/{subdir}/repodata.json'

    _load_columns = ['build', 'build_number', 'name', 'version', 'depends']

    #: Columns available in internal dataframe
    columns = _load_columns + ['channel', 'subdir', 'platform']
    #: Platforms loaded
    platforms = ['linux', 'osx', 'noarch']
    # config object
    config = None

    cache_file = None
    _df = None
    _df_ts = None

    #: default lifetime for repodata cache
    cache_timeout = 60*60*8

    @classmethod
    def register_config(cls, config):
        cls.config = config

    __instance = None
    def __new__(cls):
        """Makes RepoData a singleton"""
        if RepoData.__instance is None:
            assert RepoData.config is not None, ("bug: ensure to load config "
                                                 "before instantiating RepoData.")
            RepoData.__instance = object.__new__(cls)
        return RepoData.__instance

    def set_cache(self, cache):
        if self._df is not None:
            warnings.warn("RepoData cache set after first use", BiocondaUtilsWarning)
        else:
            self.cache_file = cache

    def set_timeout(self, timeout):
        """Set the timeout after which the repodata should be reloaded"""
        self.cache_timeout = timeout

    @property
    def channels(self):
        """Return channels to load."""
        return self.config["channels"]

    @property
    def df(self):
        """Internal Pandas DataFrame object

        Try not to use this ... the point of this class is to be able to
        change the structure in which the data is held.
        """
        if self._df_ts is not None:
            seconds = (datetime.datetime.now() - self._df_ts).seconds
        else:
            seconds = 0

        if self._df is None or seconds > self.cache_timeout:
            self._df = self._load_channel_dataframe_cached()
            self._df_ts = datetime.datetime.now()
        return self._df

    def _make_repodata_url(self, channel, platform):
        if channel == "defaults":
            # caveat: this only gets defaults main, not 'free', 'r' or 'pro'
            url_template = self.REPODATA_DEFAULTS_URL
        else:
            url_template = self.REPODATA_URL

        url = url_template.format(channel=channel,
                                  subdir=self.platform2subdir(platform))
        return url

    def _load_channel_dataframe_cached(self):
        if self.cache_file is not None and os.path.exists(self.cache_file):
            ts = datetime.datetime.fromtimestamp(os.path.getmtime(self.cache_file))
            seconds = (datetime.datetime.now() - ts).seconds
            if seconds <= self.cache_timeout:
                logger.info("Loading repodata from cache %s", self.cache_file)
                return pd.read_pickle(self.cache_file)
            else:
                logger.info("Repodata cache file too old. Reloading")

        res = self._load_channel_dataframe()

        if self.cache_file is not None:
            res.to_pickle(self.cache_file)
        return res

    def _load_channel_dataframe(self):
        repos = list(product(self.channels, self.platforms))
        urls = [self._make_repodata_url(c, p) for c, p in repos]
        descs = ["{}/{}".format(c, p) for c, p in repos]

        def to_dataframe(json_data, meta_data):
            channel, platform = meta_data
            repo = json.loads(json_data)
            df = pd.DataFrame.from_dict(repo['packages'], 'index',
                                        columns=self._load_columns)
            # Ensure that version is always a string.
            df['version'] = df['version'].astype(str)
            df['channel'] = channel
            df['platform'] = platform
            df['subdir'] = repo['info']['subdir']
            return df

        if urls:
            dfs = AsyncRequests.fetch(urls, descs, to_dataframe, repos)
            res = pd.concat(dfs)
        else:
            res = pd.DataFrame(columns=self.columns)

        for col in ('channel', 'platform', 'subdir', 'name', 'version', 'build'):
            res[col] = res[col].astype('category')
        res = res.reset_index(drop=True)

        return res

    @staticmethod
    def native_platform():
        if sys.platform.startswith("linux"):
            return "linux"
        if sys.platform.startswith("darwin"):
            return "osx"
        raise ValueError("Running on unsupported platform")

    @staticmethod
    def platform2subdir(platform):
        if platform == 'linux':
            return 'linux-64'
        elif platform == 'osx':
            return 'osx-64'
        elif platform == 'noarch':
            return 'noarch'
        else:
            raise ValueError(
                'Unsupported platform: bioconda only supports linux, osx and noarch.')



    def get_versions(self, name):
        """Get versions available for package

        Args:
          name: package name

        Returns:
          Dictionary mapping version numbers to list of architectures
          e.g. {'0.1': ['linux'], '0.2': ['linux', 'osx'], '0.3': ['noarch']}
        """
        # called from doc generator
        packages = self.df[self.df.name == name][['version', 'platform']]
        versions = packages.groupby('version').agg(lambda x: list(set(x)))
        return versions['platform'].to_dict()

    def get_latest_versions(self, channel):
        """Get the latest version for each package in **channel**"""
        # called from pypi module
        packages = self.df[self.df.channel == channel]['version']
        def max_vers(x):
            return max(VersionOrder(v) for v in x)
        vers = packages.groupby('name').agg(max_vers)

    def get_package_data(self, key=None, channels=None, name=None, version=None,
                         build_number=None, platform=None, build=None, native=False):
        """Get **key** for each package in **channels**

        If **key** is not give, returns bool whether there are matches.
        If **key** is a string, returns list of strings.
        If **key** is a list of string, returns tuple iterator.
        """
        if native:
            platform = ['noarch', self.native_platform()]

        if version is not None:
            version = str(version)

        df = self.df
        # We iteratively drill down here, starting with the (probably)
        # most specific columns. Filtering this way on a large data frame
        # is much faster than executing the comparisons for all values
        # every time, in particular if we are looking at a specific package.
        for col, val in (
                ('name', name),         # thousands of different values
                ('build', build),       # build string should vary a lot
                ('version', version),   # still pretty good variety
                ('channel', channels),  # 3 values
                ('platform', platform), # 3 values
                ('build_number', build_number), # most values 0
        ):
            if val is None:
                continue
            if isinstance(val, list) or isinstance(val, tuple):
                df = df[df[col].isin(val)]
            else:
                df = df[df[col] == val]

        if key is None:
            return not df.empty
        if isinstance(key, str):
            return list(df[key])
        return df[key].itertuples(index=False)
