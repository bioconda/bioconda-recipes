import contextlib
import datetime
import os
import os.path as op
import shutil
import tempfile
from copy import deepcopy

from ruamel_yaml import YAML
import pandas as pd
import pytest
import py

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

    dataframe = pd.DataFrame(columns=utils.RepoData.columns)
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
def recipes_folder(tmpdir: py.path.local):
    """Prepares a temp dir with '/recipes' folder as configured"""
    orig_cwd = tmpdir.chdir()
    yield tmpdir.mkdir(TEST_RECIPES_FOLDER)
    orig_cwd.chdir()


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
def config_file(tmpdir: py.path.local, case):
    """Prepares Bioconda config.yaml"""
    if 'add_root_files' in case:
        for fname, data in case['add_root_files'].items():
            with tmpdir.join(fname).open('w') as fdes:
                fdes.write(data)
        
    data = deepcopy(TEST_CONFIG_YAML)
    if 'config' in case:
        dict_merge(data, case['config'])
    config_fname = tmpdir.join(TEST_CONFIG_YAML_FNAME)
    with config_fname.open('w') as fdes:
        yaml.dump(data, fdes)

    yield config_fname


@pytest.fixture
def recipe_dir(recipes_folder: py.path.local, tmpdir: py.path.local,
               case, recipe_data):
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

    recipe_dir = recipes_folder.mkdir(recipe_data['folder'])

    with recipe_dir.join('meta.yaml').open('w') as fdes:
        yaml.dump(recipe, fdes,
                  transform=lambda l: l.replace('#{%', '{%').replace("#{{", "{{"))

    if 'add_files' in case:
        for fname, data in case['add_files'].items():
            with recipe_dir.join(fname).open('w') as fdes:
                fdes.write(data)

    if 'move_files' in case:
        for src, dest in case['move_files'].items():
            src_path = recipe_dir.join(src)
            if not dest:
                if os.path.isdir(src_path):
                    shutil.rmtree(src_path)
                else:
                    os.remove(src_path)
            else:
                dest_path = recipe_dir.join(dest)
                shutil.move(src_path, dest_path)

    yield recipe_dir
