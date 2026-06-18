#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export CPATH="${PREFIX}/include"

if [[ "$(uname)" == "Darwin" ]]; then
	cp -rf ${RECIPE_DIR}/ContigPolisher.hpp src/polish/
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	"${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}" -v

install -v -m 0755 build/bin/metaMDBG ${PREFIX}/bin
