#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"

CXX="${CXX}" cmake -S . -B build \
	-DCMAKE_CXX_FLAGS="-O3 -D_FILE_OFFSET_BITS=64 -I${PREFIX}/include ${LDFLAGS}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DBUILD_SHARED_LIBS=ON

cmake --build build/ --target install -v
