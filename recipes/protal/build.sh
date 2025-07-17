#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -ldl"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/bin

rm -rf cmake-build-release
mkdir -p cmake-build-release

echo "Step 1"
echo ${PWD}
echo "...SRCDIR= $SRC_DIR"
export VERBOSE=1

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B cmake-build-release -G Ninja \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

echo "Step 2"
echo ${PWD}
echo "ninja -C cmake-build-release -j ${CPU_COUNT} install"

ninja -C cmake-build-release -j "${CPU_COUNT}" install

cp -f protal_launcher ${PREFIX}/bin/protal
