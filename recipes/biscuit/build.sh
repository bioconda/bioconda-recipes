#!/bin/bash

# Needed for building utils dependency
export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
mkdir -p build
cd build || exit 1
cmake -S .. -B . \
	-DCMAKE_C_FLAGS="${CFLAGS} -O3 ${LDFLAGS}" \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}"
cmake --build . --target install -v
