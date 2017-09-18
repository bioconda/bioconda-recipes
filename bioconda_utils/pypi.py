import os
import requests
from conda.version import VersionOrder
from . import utils
from . import linting


def compare_recipe_to_pypi(recipe, env):
    """
    If it looks like a PyPI package, returns a tuple of
    (name, current_bioconda_version, latest_version_on_PyPI, needs_update).

    If it doesn't look like a PyPI package, then return None.

    If it looks like a PyPI package but the PyPI info can't be found (e.g.,
    "python-wget") then a tuple is returned but with a value of None for the
    latest version on PyPI and None for needs_update.
    """
    meta = utils.load_meta(os.path.join(recipe, 'meta.yaml'), env)
    current = meta['package']['version']
    name = meta['package']['name']

    try:
        source_url = meta['source']['url']
    except KeyError:
        return

    if 'pypi' in source_url:
        pypi = requests.get('http://pypi.python.org/pypi/' + name + '/json')
        if pypi.status_code == 200:
            contents = pypi.json()
            latest = contents['info']['version']
            needs_update = False
            if VersionOrder(latest) > VersionOrder(current):
                needs_update = True
            return (name, current, latest, needs_update)

        # We could do something like strip a leading `python-` off the name
        # (e.g., for python-wget) but this won't work in all cases and there
        # aren't that many of them anyway. So we just report that nothing was
        # found.
        else:
            return (name, current, None, None)


def check_all(recipe_folder, config, packages='*'):
    """
    Check all recipes against PyPI.

    Also checks against conda-forge versions.

    Returns an iterator of tuples (name, bioconda version, PyPI version,
    out-of-date, conda-forge version, action).

    Parameters
    ----------

    recipe_folder : str

    config : dict or str

    packages : str

    """
    # Identify the latest version available on conda-forge
    df = linting.channel_dataframe(channels=['conda-forge'])
    df['looseversion'] = df['version'].apply(VersionOrder)
    latest_conda_forge = df.groupby('name')['looseversion'].agg(max)

    # Only consider the latest version we can find here
    recipes = list(utils.get_latest_recipes(recipe_folder, config, packages))
    config = utils.load_config(config)
    env = list(utils.EnvMatrix(config['env_matrix']))[0]

    for recipe in recipes:
        result = compare_recipe_to_pypi(recipe, env)

        if not result:
            continue

        result = list(result)

        try:
            conda_forge_version = latest_conda_forge[result[0]]
            in_conda_forge = True

        except KeyError:
            conda_forge_version = None
            in_conda_forge = False

        # figure out what action to take
        if result[2] is None:
            action = 'unavailable-in-pypi'
        elif not result[3]:
            action = 'up-to-date'
        else:
            if in_conda_forge:
                if str(conda_forge_version) == result[2]:
                    action = 'remove-from-bioconda'
                else:
                    action = 'decide-where-to-update'
            else:
                action = 'update-bioconda'

        if result:
            yield result + [conda_forge_version, action]
