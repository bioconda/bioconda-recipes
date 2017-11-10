#!/bin/bash

if [[ $1 == "-h" ]]; then
    echo
    echo "  Sets the correct channel order required by bioconda."
    echo
    echo "    Usage: $0 [optional path to conda]"
    echo
    exit 0
fi

CONDA_BIN=conda
if [[ ! -z $CONDA_ROOT ]]; then
    CONDA_BIN=$CONDA_ROOT/bin/conda
fi

echo "NOTE: messages like 'Warning: defaults already in channels list, moving to the top' are normal and can be ignored"
set -x
$CONDA_BIN config --add channels defaults
$CONDA_BIN config --add channels conda-forge
$CONDA_BIN config --add channels bioconda
