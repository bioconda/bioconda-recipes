#!/bin/bash
set -ex

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

ARCH=$(uname -m)

if [ "${ARCH}" == "aarch64" ]; then
	export EXTRA_FLAGS="-ftree-vectorize"
else
	export EXTRA_FLAGS="-ftree-vectorize -msse2 -mfpmath=sse"
fi

cmake -S . -B build \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64 -I${PREFIX}/include ${LDFLAGS}" \
	-DEXTRA_FLAGS="${EXTRA_FLAGS}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DOPENMP=TRUE

cmake --build build/ --target install -j ${CPU_COUNT} -v
