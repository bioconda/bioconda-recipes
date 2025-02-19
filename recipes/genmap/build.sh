#!/bin/bash

rm -rf include/seqan
mv ${SRC_DIR}/seqan include/

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 --std=c++14 -I${PREFIX}/include"

if [[ "$(uname)" == "Darwin" ]]; then
	export MACOSX_DEPLOYMENT_TARGET=10.15
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DGENMAP_NATIVE_BUILD=OFF \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wno-deprecated-declarations -Wno-alloc-size-larger-than" \
	"${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"
