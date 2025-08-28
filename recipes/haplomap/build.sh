#!/bin/bash

set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# cd to location of Makefile and source
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}/bin" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	"${CONFIG_ARGS}"

cd build
make -j"${CPU_COUNT}"
make install
