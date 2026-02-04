#!/bin/bash

set -ex

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include"

if [[ "$(uname)" == "Darwin" ]]; then
	# LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
	export LDFLAGS="${LDFLAGS} -Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
	export MKL_THREADING_LAYER="GNU"
	export CONFIG_ARGS=""
fi

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export INCLUDE_PATH="${PREFIX}/include"

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	"${CONFIG_ARGS}"

cmake --build build --target install -j "${CPU_COUNT}" -v
