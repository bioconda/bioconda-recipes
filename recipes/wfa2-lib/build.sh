#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

case $(uname -m) in
    aarch64 | arm64)
        EXTRA_FLAGS="-ftree-vectorize"
        ;;
    *)
        EXTRA_FLAGS="-ftree-vectorize -msse2 -mfpmath=sse"
        ;;
esac

if [[ "$(uname)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DEXTRA_FLAGS="${EXTRA_FLAGS}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
	-DOPENMP=TRUE "${CONFIG_ARGS}"

cmake --build build/ --target install -j "${CPU_COUNT}" -v
