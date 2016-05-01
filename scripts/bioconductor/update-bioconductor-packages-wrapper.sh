#!/bin/bash

set -e

if [ -z $1 ]; then
    echo -n "

    This script finds all Bioconductor packages in the repository and updates
    all Bioconductor and R dependencies in topologically sorted order.

    - Finding and sorting Bioconductor packages and dependencies is handled by
      the update_bioconductor_packages.py script.

    - To update Bioconductor packages and dependencies we use
      bioconductor_skeleton.py --force

    - To update R packages and dependencies we use
      conda skeleton cran --update-outdated

    - Downloaded Bioconductor packages are cached in
      cached_bioconductor_tarballs. CRAN metadata is cached if you have
      CacheControl and lockfile installed, which will speed things up
      considerably:

        conda install cachecontrol lockfile


    Usage:
       $0 <repository dir>

"
    exit 1
fi

REPO="$1"
RECIPES="$1/recipes"
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
    echo "[                 wrapper $(date "+%Y-%m-%d %H:%M:%S")    ]: $1"
}

log "***Discarding un-committed R and bioconductor recipes in $RECIPES"
git checkout -- "$RECIPES/bioconductor-*" "$RECIPES/r-*"

for i in $(python "$HERE/update_bioconductor_packages.py" --repository "$REPO"); do
    bioconductor_name=$(echo "$i" | awk -F ":" '{print $1}')
    recipe_name="$(echo "$i" | awk -F ":" '{print $2}')"
    log "Updating package $bioconductor_name (recipe $recipe_name)"

    # Handle bioconductor and CRAN packages separately
    if [ $(echo "$recipe_name" | grep "^bioconductor-") ]; then
        python "$HERE/bioconductor_skeleton.py" $bioconductor_name --force --recipes "$RECIPES"
    else
        conda skeleton cran  --update-outdated --output-dir "$RECIPES/$recipe_name"
    fi
done
