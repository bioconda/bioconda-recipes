#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -I/usr/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
