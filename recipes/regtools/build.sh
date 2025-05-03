#!/bin/bash

export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

mkdir -p "${PREFIX}/bin"
mv src/utils/bedtools/gzstream/version src/utils/bedtools/gzstream/version.txt

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/regtools "${PREFIX}/bin"
