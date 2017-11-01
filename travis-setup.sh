#!/bin/bash
set -euo pipefail

# Sets up travis-ci environment for testing bioconda-utils.

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    tag=Linux
else
    tag=MacOSX
fi

curl -O https://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VER-$tag-x86_64.sh
sudo bash Miniconda3-$MINICONDA_VER-$tag-x86_64.sh -b -p /anaconda
sudo chown -R $USER /anaconda
export PATH=/anaconda/bin:$PATH

# TODO: it would be nice to have a single location where channels are
# configured across bioconda-recipes and bioconda-utils.
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda

conda config --get
conda install -y --file bioconda_utils/bioconda_utils-requirements.txt

python setup.py install

pip install -r pip-test-requirements.txt
pip install -r pip-requirements.txt

# Add local channel as highest priority
conda config --add channels file://anaconda/conda-bld
conda config --get

# involucro used for mulled-build
curl -O https://github.com/involucro/involucro/releases/download/v1.1.2/involucro
sudo mv involucro /opt/involucro
sudo chmod +x /opt/involucro
export PATH=/opt/involucro:$PATH
