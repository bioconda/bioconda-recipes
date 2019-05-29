import os.path as op
import os

import pytest

from ruamel_yaml import YAML
yaml = YAML(typ="rt")  # pylint: disable=invalid-name

from bioconda_utils.recipe import (
    Recipe,
    EmptyRecipe, MissingMetaYaml, RenderFailure, DuplicateKey, MissingKey
)

RECIPE_DATA = """
one:
  folder: one
  meta.yaml:
    #{% set version="0.1" %}
    package:
      name: one
      version: #{{version}}
    source:
      url: https://somewhere
      sha256: 123
    build:
      noarch: True
      number: 0
    test:
      commands:
        - do nothing
    about:
      license: BSD
      home: https://elsewhere
      summary: the_summary
two:
  folder: two
  meta.yaml:
    #{% set version="0.1" %}
    package:
      name: two
      version: #{{version}}
    source:
      - url: https://somewhere # [osx]
        sha256: 123            # [osx[
      - url: https://somewhere # [linux]
        sha256: 456            # [linux]
    build:
      number: 0
    outputs:
      - name: libtwo
      - name: two-tools
    test:
      commands:
        - do nothing
    about:
      license: BSD
      home: https://elsewhere
      summary: the_summary
"""
RECIPES = yaml.load(RECIPE_DATA)


@pytest.fixture
def recipe(recipe_dir, recipes_folder):
    yield Recipe.from_file(str(recipes_folder), str(recipe_dir))


def with_recipes(func):
    func = pytest.mark.parametrize('case', ({},))(func)
    func = pytest.mark.parametrize('recipe_data', RECIPES.values(), ids=list(RECIPES.keys()))(func)
    return func

    
def test_stub():
    r = Recipe('recipes/sina', 'recipes/')
    assert r.path == 'recipes/sina/meta.yaml'
    assert r.relpath == 'sina/meta.yaml'
    assert r.reldir == 'sina'
    assert str(r) == 'sina'


def test_empty_recipe(tmpdir):
    r = Recipe('recipes/sina', 'recipes/')
    with pytest.raises(EmptyRecipe):
        r.load_from_string("")
    with open(op.join(tmpdir, 'meta.yaml'), "w"):
        pass
    with pytest.raises(EmptyRecipe):
        Recipe.from_file(str(tmpdir), str(tmpdir))
    res = Recipe.from_file(str(tmpdir), str(tmpdir), return_exceptions=True)
    assert isinstance(res, EmptyRecipe)


def test_file_not_found():
    with pytest.raises(MissingMetaYaml):
        Recipe.from_file('/', '/doesnotexist')
    res = Recipe.from_file('/', '/doesnotexist', return_exceptions=True)
    assert isinstance(res, MissingMetaYaml)


@with_recipes
def test_save(recipe):
    with open(recipe.path, 'r') as fdes:
        data = fdes.read()
    os.remove(recipe.path)
    recipe.save()
    with open(recipe.path, 'r') as fdes:
        assert data == fdes.read()


@with_recipes
def test_recipe_set_original(recipe, recipe_data):
    assert recipe_data['folder'] == recipe.reldir
    assert recipe.meta == recipe.orig.meta
    recipe.meta['package']['name'] = "test"
    assert recipe.meta != recipe.orig.meta
    recipe.set_original()
    assert recipe.meta == recipe.orig.meta


@with_recipes
def test_recipe_get_template(recipe):
    recipe.get_template()
    with pytest.raises(RenderFailure):
        recipe.meta_yaml += ["{% if 1 %}"]
        recipe.get_template()


@with_recipes
def test_recipe_get_simple_modules(recipe):
    modules = recipe.get_simple_modules()
    assert 'version' in modules
    assert modules['version'] == '0.1'


@with_recipes
def test_recipe_render_duplicate_key(recipe):
    recipe.meta_yaml += ['build:']
    with pytest.raises(DuplicateKey):
        recipe.render()


def remove_section(data, section):
    start_off = None
    for num, line in enumerate(data):
        off = len(line) - len(line.lstrip())
        if section + ':' in line:
            start = num
            start_off = off
            continue
        if start_off is not None and off <= start_off:
            end = num
            break
    del data[start:end]


@with_recipes
def test_recipe_render_missing_package_section(recipe):
    remove_section(recipe.meta_yaml, 'package')
    with pytest.raises(MissingKey):
        recipe.render()


@with_recipes
def test_recipe_render_missing_version(recipe):
    remove_section(recipe.meta_yaml, 'version')
    with pytest.raises(MissingKey):
        recipe.render()


@with_recipes
def test_recipe_render_missing_name(recipe):
    remove_section(recipe.meta_yaml, 'name')
    with pytest.raises(MissingKey):
        recipe.render()


@with_recipes
def test_recipe_maintainers(recipe):
    assert recipe.maintainers == []
    recipe.meta_yaml += [
        'extra:',
        '  recipe-maintainers:',
        '    - tester'
    ]
    recipe.render()
    assert recipe.maintainers == ['tester']
    del recipe.meta_yaml[-1]
    recipe.meta_yaml[-1] += ' tester'
    recipe.render()
    assert recipe.maintainers == ['tester']


@with_recipes
def test_recipe_name_version_build(recipe, recipe_data):
    assert recipe.name == recipe_data['meta.yaml']['package']['name']
    assert recipe.version == '0.1'
    assert recipe.build_number == recipe_data['meta.yaml']['build']['number']


@with_recipes
def test_recipe_get(recipe):
    assert recipe.get('build/number') == '0'
    #assert recipe.get('source/sha256') == '123'
    with pytest.raises(KeyError):
        recipe.get('doesnot/exist')
    assert recipe.get('doesnot/exist', 'abc') == 'abc'


@with_recipes
def test_recipe_get_raw_range(recipe):
    assert recipe.get_raw_range('package') == (2, 2, 4, 0)
    assert recipe.get_raw_range('package/name') == (2, 8, 3, 2)
    end = len(recipe.meta_yaml)
    assert recipe.get_raw_range('about') == (end-3, 2, end-1, 22)
    assert recipe.get_raw_range('about/summary') == (end-1, 11, end-1, 22)


@with_recipes
def test_recipe_get_raw(recipe):
    assert recipe.get_raw('about/summary') == 'the_summary'
    assert recipe.get_raw('test/commands/0') == 'do nothing'
    assert 'number: 0' in recipe.get_raw('build')

    recipe.meta_yaml.extend([
        'testing:',
        '  inline: [1,2,3]',
        '  inline2: { a: "asd", b: "edf" }',
    ])
    recipe.render()
    assert recipe.get_raw('testing/inline') == '[1,2,3]'
    assert recipe.get('testing/inline') == ['1', '2', '3']
    assert recipe.get('testing/inline/0') == '1'
    assert recipe.get('testing/inline/1') == '2'
    assert recipe.get('testing/inline/2') == '3'
    assert recipe.get_raw('testing/inline2/a') == '"asd", '


@with_recipes
def test_recipe_set(recipe):
    recipe.set('package/bla/1', 'test')
    assert recipe.get_raw('package/bla/1') == 'test'
    recipe.set('package/bla/1', 'test2')
    assert recipe.get_raw('package/bla/1') == 'test2'
    recipe.set('package/bla/1', '[test3]')
    assert recipe.get_raw('package/bla/1') == '[test3]'
    assert recipe.get('package/bla/1') == ['test3']
    recipe.set('package/bla/1/0', 'test4')
    assert recipe.get('package/bla/1/0') == 'test4'


@with_recipes
def test_recipe_package_names(recipe):
    expected = {
        'one': ['one'],
        'two': ['two', 'libtwo', 'two-tools'],
    }[recipe.name]
    assert recipe.package_names == expected


@with_recipes
def test_get_deps_dict(recipe):
    recipe.meta_yaml.extend([
        'requirements:',
        '  build:',
        '    - AA',
        '    - BB >3',
        '    - CC>3',
        '    - DD=1.*',
        '  run:',
        '    - AA',
        '    - BB >3',
        '    - CC>3',
        '    - DD=1.*',
        '    - EE',
    ])
    recipe.render()
    deps = recipe.get_deps_dict()

    for n in 'ABCDE':
        assert n*2 in deps
