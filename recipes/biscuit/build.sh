#!/bin/bash

# Needed for building utils dependency
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

cmake -S . -B build \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS} -O3 ${LDFLAGS}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build build/ --target install -v
