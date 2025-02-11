#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CXXFLAGS="$CXXFLAGS -O3 -std=c++20 -I${PREFIX}/include"
export UC_INSTALL="conda"
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
