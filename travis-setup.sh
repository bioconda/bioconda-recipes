#!/bin/bash
set -euo pipefail

# Sets up travis-ci environment for testing bioconda-utils.

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    tag=Linux
else
    tag=MacOSX
fi
curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-${tag}-x86_64.sh
sudo bash Miniconda3-latest-${tag}-x86_64.sh -b -p /anaconda
sudo chown -R $USER /anaconda
export PATH=/anaconda/bin:$PATH

# TODO: add remaining pip reqs to conda-forge
conda install -y --file conda-requirements.txt \
    --channel anaconda \
    --channel r \
    --channel conda-forge \
    --channel bioconda

python setup.py install

pip install -r pip-test-requirements.txt
pip install -r pip-requirements.txt

set -x

# setup bioconda channel
conda config --add channels bioconda
conda config --add channels r
conda config --add channels conda-forge
conda config --add channels file://anaconda/conda-bld

# involucro used for mulled-build
curl -O https://github.com/involucro/involucro/releases/download/v1.1.2/involucro
sudo mv involucro /opt/involucro
sudo chmod +x /opt/involucro
export PATH=/opt/involucro:$PATH
