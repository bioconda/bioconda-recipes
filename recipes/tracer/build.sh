#!usr/bin/env bash

# export required env variables
export C_INCLUDE_PATH=$PREFIX/include

# https://bioconda.github.io/linting.html#setup-py-install-args
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

