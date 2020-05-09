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
            if not k.startswith('bioconductor-'):
                continue
            if 'timestamp' in v:
                if float(v['timestamp'])/1000 >= ts:
                    s.add(v['name'])
        res.append(s)
    return res


def printRootNodes(config_path, recipe_folder, onlyUploadedSince):
    config = utils.load_config(config_path)
    blacklist = utils.get_blacklist(config, recipe_folder)
    print(blacklist)
    recipes = utils.get_recipes(recipe_folder)

    if onlyUploadedSince:
       timeStamp = datetime.timestamp(datetime.now() - timedelta(onlyUploadedSince))
       linux, noarch, osx = getRepoData(timeStamp)
       arch = linux.intersection(osx)
       ready = noarch.union(arch)
       print("{} built in noarch and both archs combined: {} noarch, {} linux-64, {} osx-64".format(len(ready), len(noarch), len(linux), len(osx)))

    dag, name2recipes = graph.build(recipes, config=config_path, blacklist=blacklist)
    root_nodes = sorted([(len(nx.algorithms.descendants(dag, k)), k) for k, v in dag.in_degree().items() if v == 0 and k.startswith('bioconductor')])
    print("Package\tNumber of dependant packages")
    for n in root_nodes:
        # blacklisted packages also show up as root nodes with out degree 0
        if n[1] in blacklist:
            continue

        if onlyUploadedSince:
            if n[1] in ready:
                print("recipes/{}\t{}".format(n[1], n[0]))
        else:
            print("recipes/{}\t{}".format(n[1], n[0]))


def main():
    parser = argparse.ArgumentParser(description="""Print a list of Bioconductor package root nodes in the DAG.
The children for each are also listed. This is primarily useful during
Bioconductor builds in the bulk branch as build root nodes can be blacklisted
to spread the load more evenly over worker nodes. Note that the output is sorted
so the root nodes with the most children are at the end.""")
    parser.add_argument("config_path", default="config.yml", help="Location of config.yml (default: %(default)s", nargs='?')
    parser.add_argument("recipe_folder", default="recipes", help="Location of the recipes folder (default: %(default)s)", nargs='?')
    parser.add_argument("--onlyUploadedSince", type=int, help="If specified, only print root nodes with packages that have been uploaded to noarch or (linux64 & osx64) in the past N days, where N is the value given.")
    args = parser.parse_args()

    printRootNodes(args.config_path, args.recipe_folder, args.onlyUploadedSince)


if __name__ == '__main__':
    main()
