#!/bin/bash
set -e
set -x

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

pip install pyyaml
sudo mkdir /anaconda
sudo chown -R $USER /anaconda
$SCRIPT_DIR/../simulate-travis.py --bootstrap /anaconda --overwrite
/anaconda/bin/conda index /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64
/anaconda/bin/conda config --add channels file://anaconda/conda-bld
