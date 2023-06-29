#!/bin/bash
set -ex

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cmake -S . -B build \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="-O3 -D_FILE_OFFSET_BITS=64 -I${PREFIX}/include ${LDFLAGS}" \
	-DEXTRA_FLAGS="-ftree-vectorize -msse2 -mfpmath=sse" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DBUILD_SHARED_LIBS=ON

cmake --build build/ --target install -v
