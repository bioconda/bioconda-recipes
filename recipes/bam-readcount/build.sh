#!/bin/bash

# Needed for building utils dependency
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

mkdir build
pushd build
cmake ..
make CXX="${CXX} ${LDFLAGS}" CXXFLAGS="${CXXFLAGS} -O3"

cp bin/bam-readcount "${PREFIX}/bin"
popd
