#!/bin/bash

# fix name_install_tool issue, see https://github.com/bioconda/bioconda-recipes/pull/3124
if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi


$PYTHON setup.py install --single-version-externally-managed --record=record.txt
