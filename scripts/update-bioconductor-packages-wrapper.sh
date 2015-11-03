#!/bin/bash

# This script helps update R and BioConductor packages by attempting to bundle
# newly-updated packages together into a single pull request.
#
# It uses the output of scripts/update-bioconductor-packages.py to get the
# sorted DAG of bioconductor and R recipes defined in this repo.
#
# For each recipe, we run scripts/bioconductor-scraper.py to build
# a recipe for the latest version.
#
# If git status reports no change in that recipe, we move on.
#
# If there was a change, we immediately try testing it. If it works, we move on
# to the next -- this new recipe can be included in the PR.
#
# If it fails, we roll back the changes for the recipe that failed and then
# exit.
#
# At this point, the current changes reported by `git status recipes` can be
# bundled into a single repo. Also inspect the output to see what failed;
# usually it's a dependency that has not been added to the bioconda channel. So
# the solution is to submit a PR, merge, and wait for the built package to be
# uploaded to the bioconda channel.
#
#

set -e

# This script lives in the scripts/ dir but most paths should be specified from
# the top dir of the repo.
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP="$HERE/.."

echo -n "
Warning: this script ($0) modifies the working directory,
and discards any uncommitted changes. Continue? [yes|no]
[no] >>> "
read ans
if [[ ($ans != "yes") && ($ans != "Yes") && ($ans != "YES") &&
            ($ans != "y") && ($ans != "Y") ]]
then
    echo "Aborting!"
    exit 2
fi

function log () {
    # log output to match that of bioconductor-scraper.py
    echo "[$(date "+%Y-%m-%d %H:%M:%S")    ]: $1"
}

log "***Discarding un-committed R and bioconductor recipes"
git checkout -- recipes/bioconductor-* recipes/r-*

for i in $(python scripts/update-bioconductor-packages.py); do
    bioconductor_name=$(echo "$i" | awk -F ":" '{print $1}')
    recipe_name="$(echo "$i" | awk -F ":" '{print $2}')"
    log "Updating Bioconductor package $bioconductor_name (recipe $recipe_name)"

    # Handle bioconductor and CRAN packages separately
    if [ $(echo "$recipe_name" | grep "^bioconductor-") ]; then
        python $TOP/scripts/bioconductor-scraper.py $bioconductor_name --force
    else
        (cd $TOP/recipes && conda skeleton cran "$bioconductor_name" --update-outdated)
    fi


    ## Check git status output to see if the recipe changed
    #if [[ ! $(git status $TOP | grep "$recipe_name") ]]; then
    #    log "***$recipe_name is unchanged"
    #else
    #    # If the test fails, then roll back this recipe and exit
    #    log "***Testing $recipe_name"
    #    (
    #        cd $TOP && docker run \
    #            -v `pwd`:/bioconda-recipes bioconda/bioconda-builder \
    #            --packages "$recipe_name" \
    #            || (git checkout -- recipes/$recipe_name && exit 1)
    #    )
    #fi
done
