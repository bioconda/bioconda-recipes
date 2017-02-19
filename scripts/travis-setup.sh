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

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    tag=Linux
else
    tag=MacOSX
fi

# install conda

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    curl -O https://repo.continuum.io/archive/Anaconda2-4.3.0-Linux-x86_64.sh
    sudo bash Anaconda2-4.3.0-Linux-x86_64.sh -b -p /anaconda
else
    curl -O https://repo.continuum.io/archive/Anaconda2-4.3.0-MacOSX-x86_64.sh
    sudo bash Anaconda2-4.3.0-MacOSX-x86_64.sh -b -p /anaconda
fi

sudo chown -R $USER /anaconda
export PATH=/anaconda/bin:$PATH

$SCRIPT_DIR/../simulate-travis.py --set-channel-order
$SCRIPT_DIR/../simulate-travis.py --install-requirements

conda index /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64
conda config --add channels file://anaconda/conda-bld
