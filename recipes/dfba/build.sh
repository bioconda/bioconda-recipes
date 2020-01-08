#!/usr/bin/env bash

#export LDFLAGS="-L${PREFIX}/lib"
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPPFLAGS="-I${PREFIX}/include"

$PYTHON -m pip install -vv --no-deps --ignore-installed .
