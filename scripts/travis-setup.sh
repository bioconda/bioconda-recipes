#!/bin/bash
set -euo pipefail

[[ $TRAVIS_OS_NAME = "linux" ]] && tag=Linux || tag=MacOSX
curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-${tag}-x86_64.sh
sudo bash Miniconda3-latest-${tag}-x86_64.sh -b -p /anaconda
sudo chown -R $USER /anaconda
export PATH=/anaconda/bin:$PATH
conda install -y --file scripts/requirements.txt
pip install git+https://github.com/bioconda/bioconda-utils.git@docker-use-config
