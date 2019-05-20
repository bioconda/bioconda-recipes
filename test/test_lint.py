import os.path as op
import os
import json
import yaml
import tempfile
from copy import deepcopy

import pytest

from bioconda_utils import lint, utils
from bioconda_utils.utils import ensure_list


with open(op.join(op.dirname(__file__), "lint_cases.yaml")) as data:
    TEST_DATA = yaml.safe_load(data)

TEST_SETUP = TEST_DATA['setup']
TEST_RECIPES = list(TEST_SETUP['recipes'].values())
TEST_RECIPE_IDS = list(TEST_SETUP['recipes'].keys())
TEST_CASES = TEST_DATA['tests']
TEST_CASE_IDS = [case['name'] for case in TEST_CASES]


def dict_merge(base, add):
    for key, value in add.items():
        if isinstance(value, dict):
            base[key] = dict_merge(base.get(key, {}), value)
        elif isinstance(base, list):
            for n in range(len(base)):
                base[n][key] = dict_merge(base[n].get(key, {}), add)
        else:
            base[key] = value
    return base


@pytest.fixture
def recipes_folder(case):
    with tempfile.TemporaryDirectory() as tmpdir:
        recipes_folder = op.join(tmpdir, TEST_SETUP['recipes_folder'])
        os.mkdir(recipes_folder)
        yield recipes_folder


@pytest.fixture
def config_file(recipes_folder, case):
    config_yaml = TEST_SETUP['config.yaml']
    config_fname = op.join(op.dirname(recipes_folder), 'config.yaml')
    with open(config_fname, 'w') as config_file:
        yaml.dump(config_yaml, config_file)
    yield config_fname


@pytest.fixture
def recipe(recipes_folder, case, recipe_data):
    recipe = deepcopy(recipe_data['meta.yaml'])
    if 'remove' in case:
        for remove in ensure_list(case['remove']):
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

    recipe_folder = op.join(recipes_folder, recipe['package']['name'])
    os.mkdir(recipe_folder)

    if 'add_files' in case:
        for fname, data in case['add_files'].items():
            with open(op.join(recipe_folder, fname), "w") as out:
                out.write(data)

    with open(op.join(recipe_folder, 'meta.yaml'), "w") as meta_file:
        yaml.dump(recipe, meta_file)

    yield recipe_folder


@pytest.fixture
def linter(config_file, recipes_folder):
    config = utils.load_config(config_file)
    yield lint.Linter(config, recipes_folder)


@pytest.mark.parametrize('case', TEST_CASES, ids=TEST_CASE_IDS)
@pytest.mark.parametrize('recipe_data', TEST_RECIPES, ids=TEST_RECIPE_IDS)
def test_lint(linter, recipe, case):
    messages = linter.lint([recipe])
    expected = set(ensure_list(case.get('expect', [])))
    found = set()
    for msg in messages:
        assert str(msg.check) in expected
        found.add(str(msg.check))
    assert len(expected) == len(found)
