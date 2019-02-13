#!/bin/bash

# export required env variables
export C_INCLUDE_PATH=$PREFIX/include

# remove install_requires (no longer required with conda package)
sed -i'' -e '/REPO_REQUIREMENT/,/pass/d' setup.py
sed -i'' -e '/# dependencies/,/dependency_links=dependency_links,/d' setup.py

# proceed with actual installation
#pip install 'bx-python==0.7.3'

# https://bioconda.github.io/linting.html#setup-py-install-args
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

