#!/bin/bash
set -e
export LD_LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include

$PYTHON -m pip install --no-deps --ignore-installed .
