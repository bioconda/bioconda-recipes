#!/bin/bash
set -xe

export SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export MACOSX_DEPLOYMENT_TARGET=11.0
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

rm -rf thirdparty/gatb-core
git clone https://github.com/GATB/gatb-core.git thirdparty/gatb-core

cd thirdparty/gatb-core
git checkout e80aa72fc91bac58de11341b536c3a94ecb54719
cd ../..

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="$CXX" \
	-DCMAKE_C_COMPILER="$CC" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCPPUNIT_INCLUDE_DIR="${PREFIX}/include" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --target install -j "${CPU_COUNT}"
