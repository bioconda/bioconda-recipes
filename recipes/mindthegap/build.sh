#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -DH5_USE_110_API=1 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -D_HDF5USEDLL_=1 -DUSE_NEW_CXX"

mkdir -p $PREFIX/bin

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

sed -i.bak 's/cmake_minimum_required(VERSION 3.1)/cmake_minimum_required(VERSION 3.5...3.28)/g' CMakeLists.txt
rm -f *.bak

rm -rf thirdparty/gatb-core
git clone https://github.com/GATB/gatb-core.git thirdparty/gatb-core

cd thirdparty/gatb-core
git checkout e80aa72fc91bac58de11341b536c3a94ecb54719
cd ../..

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
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="$CC" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/bin/MindTheGap "${PREFIX}/bin"
