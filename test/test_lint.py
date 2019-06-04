import os.path as op
from ruamel_yaml import YAML

import pytest

from bioconda_utils import lint, utils
from bioconda_utils.utils import ensure_list


yaml = YAML(typ="rt")  # pylint: disable=invalid-name

with open(op.join(op.dirname(__file__), "lint_cases.yaml")) as data:
    TEST_DATA = yaml.load(data)

TEST_RECIPES = list(TEST_DATA['setup']['recipes'].values())
TEST_RECIPE_IDS = list(TEST_DATA['setup']['recipes'].keys())
TEST_CASES = TEST_DATA['tests']
TEST_CASE_IDS = [case['name'] for case in TEST_CASES]


@pytest.fixture
def linter(config_file, recipes_folder):
    """Prepares a linter given config_folder and recipes_folder"""
    config = utils.load_config(config_file)
    yield lint.Linter(config, str(recipes_folder), nocatch=True)


@pytest.mark.parametrize('repodata', (TEST_DATA['setup']['repodata'],))
@pytest.mark.parametrize('recipe_data', TEST_RECIPES, ids=TEST_RECIPE_IDS)
@pytest.mark.parametrize('case', TEST_CASES, ids=TEST_CASE_IDS)
def test_lint(linter, recipe_dir, mock_repodata, case):
    recipes = [str(recipe_dir)]
    linter.clear_messages()
    linter.lint(recipes)
    messages = linter.get_messages()
    expected = set(ensure_list(case.get('expect', [])))
    found = set()
    for msg in messages:
        assert str(msg.check) in expected, (
            f"In test '{case['name']}' on '{op.basename(recipe_dir)}':"
            f"'{msg.check}' emitted unexpectedly")
        found.add(str(msg.check))
    assert len(expected) == len(found), (
        f"In test '{case['name']}' on '{op.basename(recipe_dir)}':"
        f"missed expected lint fails")

    canfix = set(msg for msg in messages if msg.canfix and str(msg.check) in expected)
    if canfix:
        linter.clear_messages()
        linter.reload_checks()
        linter.lint(recipes, fix=True)
        found_fix = set(str(msg.check) for msg in linter.get_messages())
        for msg in canfix:
            assert str(msg.check) not in found_fix
        linter.clear_messages()
        linter.reload_checks()
        linter.lint(recipes)
        found_postfix = set(str(msg.check) for msg in linter.get_messages())
        for msg in canfix:
            assert str(msg.check) not in found_postfix
        for msgstr in found_postfix:
            assert msgstr in found
