#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

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

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=nocona -mtune=haswell|-march=armv8-a|' CMakeLists.txt
	;;
    arm64)
	sed -i.bak 's|-march=nocona -mtune=haswell|-march=armv8.4-a|' CMakeLists.txt
	;;
    x86_64)
	sed -i.bak 's|-march=nocona -mtune=haswell|-march=x86-64-v3|' CMakeLists.txt
	;;
esac

rm -f *.bak
rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Conda \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
