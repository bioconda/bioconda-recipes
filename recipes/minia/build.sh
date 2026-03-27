#!/bin/bash

export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|gatb-tool_VERSION_PATCH 5|gatb-tool_VERSION_PATCH 6|' CMakeLists.txt
rm -rf *.bak

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja -DCMAKE_CXX_FLAGS="$CXXFLAGS -DUSE_NEW_CXX" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}" minia
ninja -C build -j "${CPU_COUNT}" merci

install -v -m 0755 build/bin/* "${PREFIX}/bin"
