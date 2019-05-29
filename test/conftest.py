import contextlib
import datetime
import tempfile
import os
import os.path as op
from copy import deepcopy

from ruamel_yaml import YAML
import pandas as pd
import pytest

from bioconda_utils import utils

yaml = YAML(typ="rt")  # pylint: disable=invalid-name


# common settings
TEST_RECIPES_FOLDER = 'recipes'
TEST_CONFIG_YAML_FNAME = 'config.yaml'
TEST_CONFIG_YAML = {
    'blacklists': [],
    'channels': []
}


def pytest_runtest_makereport(item, call):
    if "successive" in item.keywords:
        # if we failed, mark parent with callspec id (name from test args)
        if call.excinfo is not None:
            item.parent.failedcallspec = item.callspec.id


def pytest_runtest_setup(item):
    if "successive" in item.keywords:
        if getattr(item.parent, "failedcallspec", None) == item.callspec.id:
            pytest.xfail("preceding test failed")


@pytest.fixture
def mock_repodata(repodata, case):
    """Pepares RepoData singleton to contain mock data

    Expects function to be parametrized with ``case`` and ``repodata``,
    where ``case`` may contain a ``repodata`` key to be added to
    base ``repodata`` contents.

    ``repodata`` should be of this form::

       <channel>:
          <package_name>:
             - <key>: value
               <key>: value

    E.g.::
       bioconda:
         package_one:
             - version: 0.1
               build_number: 0
    """
    if 'repodata' in case:
        data = deepcopy(repodata)
        dict_merge(data, case['repodata'])
    else:
        data = repodata

    dataframe = pd.DataFrame(columns = utils.RepoData.columns)
    for channel, packages in data.items():
        for name, versions in packages.items():
            for item in versions:
                pkg = {
                    'channel': channel,
                    'name': name,
                    'build': '',
                    'build_number': 0,
                    'version': 0,
                    'depends': [],
                    'subdir': '',
                    'platform': 'noarch',
                }
                pkg.update(item)
                dataframe = dataframe.append(pkg, ignore_index=True)

    backup = utils.RepoData()._df, utils.RepoData()._df_ts
    utils.RepoData()._df = dataframe
    utils.RepoData()._df_ts = datetime.datetime.now()
    yield
    utils.RepoData()._df, utils.RepoData()._df_ts = backup


@pytest.fixture
def recipes_folder():
    """Prepares a temp dir with '/recipes' folder as configured"""
    with tempfile.TemporaryDirectory() as tmpdir:
        folder = op.join(tmpdir, TEST_RECIPES_FOLDER)
        os.mkdir(folder)
        yield folder


@pytest.fixture
def config_file(recipes_folder):
    """Prepares a Bioconda config.yaml  in a recipes_folder"""
    config_fname = op.join(op.dirname(recipes_folder), TEST_CONFIG_YAML_FNAME)
    with open(config_fname, 'w') as fdes:
        yaml.dump(TEST_CONFIG_YAML, fdes)
    yield config_fname



def dict_merge(base, add):
    for key, value in add.items():
        if isinstance(value, dict):
            base[key] = dict_merge(base.get(key, {}), value)
        elif isinstance(base, list):
            for num in range(len(base)):
                base[num][key] = dict_merge(base[num].get(key, {}), add)
        else:
            base[key] = value
    return base


@pytest.fixture
def recipe_dir(recipes_folder, case, recipe_data):
    """Prepares a recipe from recipe_data in recipes_folder"""
    recipe = deepcopy(recipe_data['meta.yaml'])
    if 'remove' in case:
        for remove in utils.ensure_list(case['remove']):
            path = remove.split('/')
            cont = recipe
            for p in path[:-1]:
                cont = cont[p]
            if isinstance(cont, list):
                for n in range(len(cont)):
                    del cont[n][path[-1]]
            else:
                del cont[path[-1]]
    if 'add' in case:
        dict_merge(recipe, case['add'])

    recipe_folder = op.join(recipes_folder, recipe_data['folder'])
    os.mkdir(recipe_folder)

    with open(op.join(recipe_folder, 'meta.yaml'), "w") as meta_file:
        yaml.dump(recipe, meta_file,
                  transform=lambda l: l.replace('#{%', '{%').replace("#{{", "{{"))

    if 'add_files' in case:
        for fname, data in case['add_files'].items():
            with open(op.join(recipe_folder, fname), "w") as out:
                out.write(data)


    yield recipe_folder
