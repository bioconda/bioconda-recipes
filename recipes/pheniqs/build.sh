#!/usr/bin/env bash

export INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/rapidjson"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/rapidjson"
export CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/rapidjson"

export CXXFLAGS="${LDFLAGS} ${CPPFLAGS}"

export LD_LIBRARY_PATH=$PREFIX/lib

set -x -e

make
