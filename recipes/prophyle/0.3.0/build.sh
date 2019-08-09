#! /usr/bin/env bash

set -e
set -o pipefail

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make -C prophyle
PROPHYLE_PACKBIN=1 $PYTHON setup.py install --single-version-externally-managed --record=record.txt
