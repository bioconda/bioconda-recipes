import os
import re
import itertools
from collections import defaultdict

import pandas as pd
import numpy as np
import ruamel_yaml as yaml
import jinja2

from . import utils
from . import lint_functions

import logging
logger = logging.getLogger(__name__)

"""
QC checks (linter) for recipes, returning a TSV of issues identified.

The strategy here is to use simple functions that do a single check on
a recipe. When run on a single recipe it can be used for linting new
contributions; when run on all recipes it helps highlight entire classes of
problems to be addressed.

See the `lint_functions` module for these.

After writing the function, register it in the global `registry` dict,
`lint_functions.registry`.

The output is a TSV where the "info" column contains the dicts returned by
each check function, and this column is expanded into multiple extra colums.
While this results in a lot of NaNs, it makes it easy to drop non-interesting
cases with pandas, e.g.,

   recipes_with_missing_tests = df.dropna(subset=['no_tests'])

or

    def not_in_bioconda(x):
        if not isinstance(x, set):
            return np.nan
        res = set(x).difference(['bioconda'])
        if len(res):
            return(res)
        return np.nan

    df['other'] = df.exists_in_channel.apply(not_in_bioconda)
    other_channels = df[['recipe', 'other']].dropna()


---------------------------------------------------------------------------
TODO:

- check version and build number against master branch. I think there's stuff
  in bioconductor updating to handle this sort of thing. Also bioconda_utils
  has utils for checking against master branch.

  - if version changed, ensure build number is 0
  - if version unchanged, ensure build number incremented

- currently we only check a single environment (see the `get_meta` function).
  This should probably be converted to a generator function.

- currently we don't pay attention to py27/py3. It would be nice to handle
  that.

- how to define valid licenses?
  (conda_build.metadata.ensure_valid_license_family is for family)

- gcc/llvm have their respective preprocessing selectors

- excessive comments (from skeletons?)
"""


usage = """
Perform various checks on recipes.
"""


def get_meta(recipe, config):
    """
    Given a package name, find the current meta.yaml file, parse it, and return
    the dict.

    Parameters
    ----------
    recipe : str
        Path to recipe (directory containing the meta.yaml file)

    config : str or dict
        Config YAML or dict
    """
    cfg = utils.load_config(config)

    # TODO: Currently just uses the first env. Should turn this into
    # a generator.

    env = dict(next(iter(utils.EnvMatrix(cfg['env_matrix']))))

    pth = os.path.join(recipe, 'meta.yaml')
    jinja_env = jinja2.Environment()
    content = jinja_env.from_string(
        open(pth, 'r', encoding='utf-8').read()).render(env)
    meta = yaml.round_trip_load(content, preserve_quotes=True)
    return meta


def channel_dataframe(cache=None, channels=['bioconda', 'conda-forge',
                                            'defaults']):
    """
    Return channel info as a dataframe.

    Parameters
    ----------

    cache : str
        Filename of cached channel info

    channels : list
        Channels to include in the dataframe
    """
    if cache is not None and os.path.exists(cache):
        df = pd.read_table(cache)
    else:
        # Get the channel data into a big dataframe
        dfs = []
        for platform in ['linux', 'osx']:
            for channel in channels:
                repo, noarch = utils.get_channel_repodata(channel, platform)
                x = pd.DataFrame(repo)
                x = x.drop([
                    'arch',
                    'default_numpy_version',
                    'default_python_version',
                    'platform',
                    'subdir'])
                for k in [
                    'build', 'build_number', 'name', 'version', 'license',
                    'platform'
                ]:
                    x[k] = x['packages'].apply(lambda y: y.get(k, np.nan))

                x['channel'] = channel
                dfs.append(x)

        df = pd.concat(dfs).drop(['info', 'packages'], axis=1)

        if cache is not None:
            df.to_csv(cache, sep='\t')
    return df


def lint(recipes, config, df, exclude=None, registry=None):
    """
    Parameters
    ----------

    recipes : list
        List of recipes to lint

    config : str, dict
        Used to pass any necessary environment variables (CONDA_BOOST, etc) to
        meta.yaml files. If str, path to config file. If dict, parsed version
        of the config file.

    df : pandas.DataFrame
        Dataframe containing channel data, typically as output from
        `channel_dataframe()`

    exclude : list
        List of function names in `registry` to skip globally. When running on
        travis, this will be merged with anything else detected from the commit
        message or LINT_SKIP environment variable using the special string
        "[skip lint <function name> for <recipe name>]". While those other
        mechanisms define skipping on a recipe-specific basis, this argument
        can be used to skip tests for all recipes. Use sparingly.

    registry : list or tuple
        List of functions to apply to each recipe. If None, defaults to
        `lint_functions.registry`.
    """

    if registry is None:
        registry = lint_functions.registry

    skip_dict = defaultdict(list)

    # We want to get the commit message of HEAD to see if we should skip any
    # linting tests. However, for PRs, travis tests the merge from PR to
    # master. This means that we can't rely on "TRAVIS_COMMIT_MESSAGE" env var
    # since, for PRs, it will be "merge $hash into $hash".
    #
    # For PRs, we need TRAVIS_PULL_REQUEST_SHA
    #
    # If not on travis, then don't look for any commit messages.
    commit_message = ""

    on_travis = os.environ.get('TRAVIS') == 'true'
    pull_request = os.environ.get('TRAVIS_PULL_REQUEST', 'false') != 'false'

    if not on_travis and 'LINT_SKIP' in os.environ:
        commit_message = os.environ['LINT_SKIP']

    if on_travis and pull_request:
        p = utils.run(
            ['git', 'log', '--format=%B', '-n', '1',
             os.environ['TRAVIS_PULL_REQUEST_SHA']]
        )
        commit_message = p.stdout

    # For example the following text in the commit message will skip
    # lint_functions.uses_setuptools for recipe argparse:
    #
    # [ lint skip uses_setuptools for argparse ]

    skip_re = re.compile(
        r'\[\s*lint skip (?P<func>\w+) for (?P<recipe>.*?)\s*\]')
    to_skip = skip_re.findall(commit_message)

    if exclude is not None:
        # exclude arg is used to skip test for *all* packages
        to_skip += list(itertools.product(exclude, recipes))

    for func, recipe in to_skip:
        skip_dict[recipe].append(func)

    hits = []
    for recipe in recipes:
        # Since lint functions need a parsed meta.yaml, checking for parsing
        # errors can't be a lint function.
        #
        # TODO: do we need a way to skip this the same way we can skip lint
        # functions? I can't think of a reason we'd want to keep an unparseable
        # YAML.
        try:
            meta = get_meta(recipe, config)
        except (
            yaml.scanner.ScannerError, yaml.constructor.ConstructorError
        ) as e:
            result = {'parse_error': str(e)}
            hits.append(
                {'recipe': recipe,
                 'check': 'parse_error',
                 'severity': 'ERROR',
                 'info': result})
            continue
        logger.debug('lint {}'.format(recipe))

        # skips defined in commit message
        skip_for_this_recipe = skip_dict[recipe]

        # skips defined in meta.yaml
        persistent = meta.get('extra', {}).get('skip-lints', [])
        skip_for_this_recipe += persistent

        for func in registry:
            if func.__name__ in skip_for_this_recipe:
                logger.info(
                    'Commit message defines skip lint test %s for recipe %s'
                    % (func.__name__, recipe))
                continue
            result = func(recipe, meta, df)
            if result:
                hits.append(
                    {'recipe': recipe,
                     'check': func.__name__,
                     'info': result})

    if hits:
        report = pd.DataFrame(hits)[['recipe', 'check', 'info']]

        # expand out the info into more columns
        info = pd.DataFrame(list(report['info'].values))
        report = pd.concat((report, info), axis=1)
        return report
    else:
        return


def markdown_report(report=None):
    """
    Return a rendered Markdown string.

    Parameters
    ----------
    report : None or pandas.DataFrame
        If None, linting assumed to be successful. If dataframe, it's provided
        to the lint failure template.
    """
    if report is None:
        tmpl = utils.jinja.get_template("lint_success.md")
        return tmpl.render()
    else:
        tmpl = utils.jinja.get_template("lint_failure.md")
        return tmpl.render(report=report)


def bump_build_number(d):
    """
    Increase the build number of a recipe, adding the relevant keys if needed.

    d : dict-like
        Parsed meta.yaml, from get_meta()
    """
    if 'build' not in d:
        d['build'] = {'number': 0}
    elif 'number' not in d['build']:
        d['build']['number'] = 0
    d['build']['number'] += 1
    return d
