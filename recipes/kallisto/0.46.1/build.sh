#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${ARCH}" == "aarch64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	sed -i.bak 's|--host=x86_64|--host=aarch64|' CMakeLists.txt
elif [[ "${ARCH}" == "arm64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	sed -i.bak 's|--host=x86_64|--host=arm64|' CMakeLists.txt
else
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

mkdir -p "${PREFIX}/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* ext/htslib/

sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|VERSION 2.8.8|VERSION 3.5|' ext/catch/CMakeLists.txt
rm -rf *.bak

cd ext/htslib
autoreconf -if
cd ../..

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S. -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j 1
