#!/usr/bin/env python
import argparse
from itertools import chain
import networkx as nx
import requests
from bioconda_utils import utils


def getRepoData():
    res = set()
    for subdir in ["linux-64", "noarch", "osx-64", "linux-aarch64", "osx-arm64"]:
        for channel in ["conda-forge", "bioconda"]:
            r = requests.get(f"https://conda.anaconda.org/{channel}/{subdir}/repodata.json")
            for k, v in chain(r.json()["packages"].items(), r.json()["packages.conda"].items()):
                if k.startswith("r-"):
                    res.add(v["name"])
    return res


def getDag(js):
    dag = nx.DiGraph()
    for k, v in js["_feedstock_status"].items():
        dag.add_node(k)
        children = v["immediate_children"]
        dag.add_edges_from((k, dep) for dep in set(children))
    return dag


def getCondaForgeMigrationStatus(migration_id):
    r = requests.get(f"https://raw.githubusercontent.com/regro/cf-graph-countyfair/master/status/migration_json/{migration_id}.json")
    js = r.json()
    depDag = getDag(js)
    res = {
        "in-pr": dict(),
        "bot-error": dict(),
        "not-solvable": dict(),
        "awaiting-parents": dict(),
        "dag": depDag,
    }
    for recipe in js["in-pr"]:
        res["in-pr"][recipe] = f"`{recipe}`: In PR {js['_feedstock_status'][recipe]['pr_url']}"
    for recipe in js["bot-error"]:
        status = js["_feedstock_status"][recipe]["pre_pr_migrator_status"]
        segment = status.split("\n")
        res["bot-error"][recipe] = f"`{recipe}`: {segment[0] + ' ' + segment[1]}"
    for recipe in js["not-solvable"]:
        status = js["_feedstock_status"][recipe]["pre_pr_migrator_status"]
        segment1 = status.split("\n")[0]
        segment2 = status.split(":")[3].split("\n")[0]
        res["not-solvable"][recipe] = f"`{recipe}`: {segment1 + ' ' + segment2}"
    for recipe in js["awaiting-parents"]:
        res["awaiting-parents"][recipe] = f"`{recipe}`: Awaiting parents"
    return res


def printMissingCRAN(recipe_folder, migration_id, format):
    # Construct a set of all dependencies (ignoring versions)
    recipes = utils.get_recipes(recipe_folder)
    dependencies = set()
    for r in recipes:
        if "bioconductor" not in r:
            continue
        d = utils.load_meta_fast(r)[0]  # a dictionary with keys requirements, build, etc.
        if d["requirements"]["run"] is None:
            continue
        for dep in d["requirements"]["run"]:
            if dep.startswith("r-"):
                dependencies.add(dep.split(" ")[0])

    CHECKBOX = "- [ ]"
    # Find packages waiting for a migration
    if migration_id:
        cf = getCondaForgeMigrationStatus(migration_id)
        dag = cf["dag"]

        # Update dependencies based on DAG from conda-forge migration data
        awaiting_parents = set.intersection(dependencies, set(cf["awaiting-parents"].keys()))
        for recipe in awaiting_parents:
            dependencies = set.union(dependencies, nx.algorithms.ancestors(dag, recipe))
        # Now that we expanded dependencies, get the new list of awaiting parents
        awaiting_parents = set.intersection(dependencies, set(cf["awaiting-parents"].keys()))
        in_pr = set.intersection(dependencies, set(cf["in-pr"].keys()))
        bot_error = set.intersection(dependencies, set(cf["bot-error"].keys()))
        not_solvable = set.intersection(dependencies, set(cf["not-solvable"].keys()))
        if format == "markdown":
            print(
                "## Awaiting migration of {} packages ##".format(
                    len(in_pr) + len(bot_error) + len(not_solvable) + len(awaiting_parents)
                )
            )
            print("### In PR ({} packages) ###".format(len(in_pr)))
            for recipe in in_pr:
                print(CHECKBOX, cf["in-pr"][recipe])
            print("### Bot Error ({} packages) ###".format(len(bot_error)))
            for recipe in bot_error:
                print(CHECKBOX, cf["bot-error"][recipe])
            print("### Not Solvable ({} packages) ###".format(len(not_solvable)))
            for recipe in not_solvable:
                print(CHECKBOX, cf["not-solvable"][recipe])
            print("### Awaiting Parents ({} packages) ###".format(len(awaiting_parents)))
            for recipe in awaiting_parents:
                print(
                    CHECKBOX,
                    cf["awaiting-parents"][recipe],
                    "(",
                    ", ".join([r for r in nx.algorithms.ancestors(dag, recipe) if r in set.union(in_pr, bot_error, not_solvable, awaiting_parents)]),
                    ")",
                )
        else:
            print("In PR:")
            for recipe in in_pr:
                print(recipe)
            print("Bot Error:")
            for recipe in bot_error:
                print(recipe)
            print("Not Solvable:")
            for recipe in not_solvable:
                print(recipe)
            print("Awaiting Parents:")
            for recipe in awaiting_parents:
                print(recipe)

    # Find missing packages
    repo = getRepoData()
    missing = dependencies - repo
    if format == "markdown":
        print("## Missing {} packages ##".format(len(missing)))
        for recipe in missing:
            print(CHECKBOX, recipe)
    else:
        print("Missing:")
        for recipe in missing:
            print(recipe)


def main():
    parser = argparse.ArgumentParser(
        description="""Print a list of missing CRAN dependencies for Bioconductor packages."""
    )
    parser.add_argument(
        "recipe_folder",
        default="recipes",
        help="Location of the recipes folder (default: %(default)s)",
        nargs="?",
    )
    parser.add_argument(
        "--migration_id",
        help="See conda-forge status page. If populated, will report packages held up in a conda-forge migration (default: None)",
        nargs="?",
    )
    parser.add_argument(
        "--format",
        dest="format",
        default="plain",
        help="Format of results: ['plain', 'markdown'] (default: %(default)s)",
        nargs="?",
    )
    args = parser.parse_args()

    printMissingCRAN(args.recipe_folder, args.migration_id, args.format)


if __name__ == "__main__":
    main()
