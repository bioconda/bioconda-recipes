#!/usr/bin/env bash

#export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

$PYTHON -m pip install -vv --no-deps --ignore-installed .
