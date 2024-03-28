#!/bin/bash

export CFLAGS="${CFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

$PYTHON -m pip install . -vvv --no-deps --no-build-isolation
