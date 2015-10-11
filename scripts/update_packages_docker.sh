#!/bin/bash
set -eu -o pipefail

# # enable gcc-4.8
# export MANPATH=""
# source /opt/rh/devtoolset-2/enable
# #
# mkdir -p /tmp/conda-build
# cd /tmp/conda-build
# rm -rf /anaconda
# wget http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
# bash Miniconda-latest-Linux-x86_64.sh -b -p /tmp/conda-build/anaconda
# export PATH=/tmp/conda-build/anaconda/bin:$PATH
# conda install -y conda conda-build anaconda-client pyyaml toolz jinja2
cd /bioconda
anaconda login --hostname bcbio-conda-auto --username `cat anaconda-user.txt` --password `cat anaconda-pass.txt`
python scripts/update_packages.py $*
