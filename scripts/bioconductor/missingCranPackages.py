#!/usr/bin/env python
import argparse
import networkx as nx
from datetime import datetime, timedelta
import requests
from bioconda_utils import utils, graph


def getRepoData():
    res = set()
    for subdir in ["linux-64", "noarch", "osx-64"]:
        for channel in ["conda-forge", "bioconda"]:
            r = requests.get(f"https://conda.anaconda.org/{channel}/{subdir}/repodata.json")
            js = r.json()['packages']
            for k, v in r.json()['packages'].items():
                if k.startswith('r-'):
                    res.add(v['name'])
    return res


def printMissingCRAN(config_path, recipe_folder):
    config = utils.load_config(config_path)
    recipes = utils.get_recipes(recipe_folder)

    repo = getRepoData()

    # Construct a set of all dependencies (ignoring versions)
    dependencies = set()
    for r in recipes:
        if "bioconductor" not in r:
            continue
        d = utils.load_meta_fast(r)[0]  # a dictionary with keys requirements, build, etc.
        if d['requirements']['run'] is None:
            continue
        for dep in d['requirements']['run']:
            if dep.startswith('r-'):
                dependencies.add(dep.split(' ')[0])

    missing = dependencies - repo
    print("Missing {} packages!".format(len(missing)))
    for m in missing:
        print(m)


def main():
    parser = argparse.ArgumentParser(description="""Print a list of missing CRAN dependencies for Bioconductor packages.""")
    parser.add_argument("config_path", default="config.yml", help="Location of config.yml (default: %(default)s", nargs='?')
    parser.add_argument("recipe_folder", default="recipes", help="Location of the recipes folder (default: %(default)s)", nargs='?')
    args = parser.parse_args()

    printMissingCRAN(args.config_path, args.recipe_folder)


if __name__ == '__main__':
    main()
