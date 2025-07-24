#!/bin/bash

mkdir -p "${PREFIX}/bin"

export C_INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

sed -i.bak 's|VERSION 3.1|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

cmake -S . -B . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DOPENCL_INCLUDE_DIR="${PREFIX}/include" \
	-DOPENCL_LIBRARY="${PREFIX}/lib/libOpenCL.so" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build . --clean-first -j "${CPU_COUNT}"

install -v -m 0755 cas-offinder "${PREFIX}/bin"
