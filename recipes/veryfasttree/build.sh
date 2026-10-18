#!/bin/bash

mkdir -p $PREFIX/bin

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include"

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	export SIMD_LEVEL="-DUSE_SEE4=ON"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "x86_64" ]]; then
	export SIMD_LEVEL="-DUSE_AVX2=ON"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export SIMD_LEVEL="-DUSE_SEE2=OFF"
else
	export SIMD_LEVEL=""
fi

if [[ "$(uname)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DUSE_NATIVE=OFF \
	"${CONFIG_ARGS}" \
	"${SIMD_LEVEL}"

cmake --build build --target install -j "${CPU_COUNT}" -v

chmod 0755 ${PREFIX}/bin/VeryFastTree
