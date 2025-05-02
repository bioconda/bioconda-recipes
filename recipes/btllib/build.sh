#!/bin/bash

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include -D_LIBCPP_DISABLE_AVAILABILITY"

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" meson setup --buildtype release --prefix "${PREFIX}" --strip build/ -Db_coverage=false

cd build

ninja -v install

# python wrappers:
$PYTHON -m pip install "${PREFIX}/lib/btllib/python" --no-deps --no-build-isolation -vvv
