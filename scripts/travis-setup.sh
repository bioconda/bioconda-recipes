#!/bin/bash
set -euo pipefail

[[ $TRAVIS_OS_NAME = "linux" ]] && tag=Linux || tag=MacOSX
curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-${tag}-x86_64.sh
bash Miniconda3-latest-${tag}-x86_64.sh -b -p /tmp/anaconda
export PATH=/tmp/anaconda/bin:$PATH
conda install -y --file scripts/requirements.txt
pip install git+https://github.com/bioconda/bioconda-utils.git
chmod -R 777 /tmp/anaconda
ls -lrth /tmp/anaconda
echo "$UID"
echo "$USER"

