#!/usr/bin/env python
import argparse
import networkx as nx
from datetime import datetime, timedelta
import requests
from bioconda_utils import utils, graph


def getRepoData(ts):
    res = []
    for subdir in ["linux-64", "noarch", "osx-64"]:
        r = requests.get(f"https://conda.anaconda.org/bioconda/{subdir}/repodata.json")
        js = r.json()['packages']
        s = set()
        for k, v in r.json()['packages'].items():
            if 'timestamp' in v:
                if float(v['timestamp'])/1000 >= ts:
                    s.add(v['name'])
        res.append(s)
    return res


def printRootNodes(config_path, recipe_folder, sinceNDays, missing, rootNodes):
    config = utils.load_config(config_path)
    blacklist = utils.get_blacklist(config, recipe_folder)
    recipes = utils.get_recipes(recipe_folder)

    if sinceNDays:
        timeStamp = datetime.timestamp(datetime.now() - timedelta(sinceNDays))
        linux, noarch, osx = getRepoData(timeStamp)
        arch = linux.intersection(osx)
        ready = noarch.union(arch)
        print("{} built in noarch and both archs combined: {} noarch, {} linux-64, {} osx-64".format(len(ready), len(noarch), len(linux), len(osx)))
    timeStamp = datetime.timestamp(datetime.now() - timedelta(360))
    linux, noarch, osx = getRepoData(timeStamp)

    dag, name2recipes = graph.build(recipes, config=config_path, blacklist=blacklist)
    if not rootNodes:
        root_nodes = sorted([(len(nx.algorithms.descendants(dag, k)), k) for k, v in dag.in_degree().items()])
    else:
        root_nodes = sorted([(len(nx.algorithms.descendants(dag, k)), k) for k, v in dag.in_degree().items() if v == 0])

    print("Package\tNumber of dependant packages")
    for n in root_nodes:
        # blacklisted packages also show up as root nodes with out degree 0
        if n[1] in blacklist:
            continue

        if sinceNDays:
            if n[1] in ready:
                if not missing:
                    print("recipes/{}\t{}".format(n[1], n[0]))
            elif missing:
                print("recipes/{}\t{}".format(n[1], n[0]))
        else:
            if n[1] in noarch:
                print("recipes/{}\t{}".format(n[1], n[0]))


def main():
    parser = argparse.ArgumentParser(description="""Print a list of (missing) packages in the DAG.
The children for each are also listed. Optionally, all root nodes (or only those
that haven't yet been built) can be printed.""")
    parser.add_argument("config_path", default="config.yml", help="Location of config.yml (default: %(default)s", nargs='?')
    parser.add_argument("recipe_folder", default="recipes", help="Location of the recipes folder (default: %(default)s)", nargs='?')
    parser.add_argument("--sinceNDays", metavar='n', type=int, help="If specified, only root nodes with packages that have been uploaded (or not) to noarch or (linux64 & osx64) in the past N days, where N is the value given.")
    parser.add_argument('--rootNodes', action='store_true', help='Only print root nodes (i.e., those with no non-blacklisted Bioconda dependencies)')
    parser.add_argument('--missing', action='store_true', help='Only print root nodes that are missing in at least one subdirectory')
    args = parser.parse_args()

    printRootNodes(args.config_path, args.recipe_folder, args.sinceNDays, args.missing, args.rootNodes)


if __name__ == '__main__':
    main()
