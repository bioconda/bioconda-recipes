#!/bin/bash
if [[ $TRAVIS_OS_NAME == "linux" ]]; then
    tag="Linux"
else
    tag="MacOSX"
fi
curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-$tag-x86_64.sh
sudo bash Miniconda3-latest-$tag-x86_64.sh -b -p /anaconda
sudo chown -R $USER /anaconda
mkdir -p /anaconda/conda-bld/osx-64 # workaround for bug in current conda
mkdir -p /anaconda/conda-bld/linux-64 # workaround for bug in current conda
export PATH=/anaconda/bin:$PATH
pip install -r requirements.txt
pip install -r test-requirements.txt
python setup.py develop
