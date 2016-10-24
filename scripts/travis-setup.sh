#!/bin/bash
set -e

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
mkdir -p /anaconda/conda-bld/osx-64
mkdir -p /anaconda/conda-bld/linux-64
export PATH=/anaconda/bin:$PATH
conda install -y --file https://raw.githubusercontent.com/bioconda/bioconda-utils/$BIOCONDA_UTILS_TAG/conda-requirements.txt
conda index /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64

# setup bioconda channel
conda config --add channels bioconda
conda config --add channels r
conda config --add channels file://anaconda/conda-bld

# setup bioconda-utils
pip install git+https://github.com/galaxyproject/galaxy-lib.git@871c090
pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG
