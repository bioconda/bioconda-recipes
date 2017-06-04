#!/bin/bash
set -e
set -x

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_REPO_SLUG == "bioconda/bioconda-recipes" ]]
then
    echo ""
    echo "Setup is skipped for pushes to the main bioconda-recipes repo."
    echo ""
    exit 0
fi

for dir in . recipes
do
    if [ -e $dir/meta.yaml ]
    then
        echo "Recipe $dir/meta.yaml found in invalid location."
        echo "Recipes must be stored in a subfolder of the recipes directory."
        exit 1
    fi
done

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    tag=Linux
else
    tag=MacOSX
fi

# install conda
curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-$tag-x86_64.sh
sudo bash Miniconda3-latest-$tag-x86_64.sh -b -p /anaconda
sudo chown -R $USER /anaconda
export PATH=/anaconda/bin:$PATH

$SCRIPT_DIR/../simulate-travis.py --set-channel-order
$SCRIPT_DIR/../simulate-travis.py --install-requirements

conda index /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64
conda config --add channels file://anaconda/conda-bld
