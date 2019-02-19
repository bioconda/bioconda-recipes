#!/bin/bash

set -x -e

mkdir -p "${PREFIX}/bin"

export INCLUDE_PATH="${PREFIX}/include/:${PREFIX}/include/bamtools/"
export LIBRARY_PATH="${PREFIX}/lib"

export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"

export BAMTOOLS_INCLUDE_DIR="${PREFIX}/include/bamtools/"
export BAMTOOLS_LIBRARY_DIR="${PREFIX}/lib/"

export GLPK_INCLUDE_DIR="${PREFIX}/include"
export GLPK_LIBRARY_DIR="${PREFIX}/lib"

export CXXFLAGS="-std=c++11 -I ${INCLUDE_PATH} -I ${BAMTOOLS_INCLUDE_DIR} -I ${BOOST_INCLUDE_DIR} -I ${GLPK_INCLUDE_DIR} -g"
export LDADD="${BAMTOOLS_LIBRARY_DIR}/libbamtools.a ${GLPK_LIBRARY_DIR}/libglpk.a"
export LDLIBS="-L${LIBRARY_PATH} -lz -lm -g"

if [[ "$(uname)" == Darwin ]]; then
    export CC=clang
    export CXX=clang++
    export DYLD_LIBRARY_PATH="${GLPK_LIBRARY_DIR}:${BAMTOOLS_LIBRARY_DIR}"
fi

make CXXFLAGS="${CXXFLAGS}" LDADD="${LDADD}" LDLIBS="${LDLIBS}"

cp bin/squid ${PREFIX}/bin
