#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DBUILD_CUDA=OFF -DBUILD_OPENCL=OFF"
else
	export CONFIG_ARGS=""
fi

if [[ "${ARCH}" == "arm64" ]]; then
	sed -i.bak 's|true|False|' CMakeLists.txt
	sed -i.bak 's|"arm64;x86_64"|"arm64"|' CMakeLists.txt
	export CONFIG_ARGS="${CONFIG_ARGS} -DBUILD_SSE=OFF"
fi

sed -i.bak 's|-std=c++11|-std=c++14|' CMakeLists.txt
rm -rf *.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
