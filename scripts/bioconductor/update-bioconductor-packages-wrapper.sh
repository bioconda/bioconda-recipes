#!/bin/bash

# This script helps update R and BioConductor packages by attempting to bundle
# newly-updated packages together into a single pull request.
#
# It uses the output of scripts/update_bioconductor_packages.py to get the
# sorted DAG of bioconductor and R recipes defined in this repo.
#
# For each recipe, we run bioconductor_skeleton.py to build a recipe for the
# latest version, or conda skeleton cran --update-outdated to build R packages.
#

set -e

if [ -z $1 ]; then
    echo
    echo "usage:"
    echo "   $0 <recipe dir>"
    echo
    exit 1
fi

RECIPES="$1"
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -n "
Warning: this script ($0) modifies the working directory, and discards any
uncommitted changes in the recipe dir $RECIPES. Continue?
[yes|no] [no] >>> "
read ans
if [[ ($ans != "yes") && ($ans != "Yes") && ($ans != "YES") &&
            ($ans != "y") && ($ans != "Y") ]]
then
    echo "Aborting!"
    exit 2
fi

function log () {
    # log output to match that of bioconductor_skeleton.py
    echo "[$(date "+%Y-%m-%d %H:%M:%S")    ]: $1"
}

log "***Discarding un-committed R and bioconductor recipes in $RECIPES"
git checkout -- "$RECIPES/bioconductor-*" "$RECIPES/r-*"

for i in $(python "$HERE/update_bioconductor_packages.py" --recipes "$RECIPES"); do
    bioconductor_name=$(echo "$i" | awk -F ":" '{print $1}')
    recipe_name="$(echo "$i" | awk -F ":" '{print $2}')"
    log "Updating Bioconductor package $bioconductor_name (recipe $recipe_name)"

    # Handle bioconductor and CRAN packages separately
    if [ $(echo "$recipe_name" | grep "^bioconductor-") ]; then
        python "$HERE/bioconductor_skeleton.py" $bioconductor_name --force --recipes "$RECIPES"
    else
        (cd "$RECIPES" && conda skeleton cran "$bioconductor_name" --update-outdated)
    fi
done
