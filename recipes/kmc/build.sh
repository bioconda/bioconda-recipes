#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

sed -i.bak 's|g++-11|$(CXX)|' Makefile
sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-m64|-march=x86-64-v3|' Makefile
rm -rf *.bak
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' 3rd_party/cloudflare/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' 3rd_party/cloudflare/ucm.cmake
rm -rf 3rd_party/cloudflare/*.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
