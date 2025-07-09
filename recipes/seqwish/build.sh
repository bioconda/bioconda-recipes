#!/bin/bash
set -xe

export LIBRARY_PATH="${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

EXTRA_FLAGS="-Ofast"

case $(uname -m) in
    aarch64)
	EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8-a"
	;;
    arm64)
	EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8.4-a"
	;;
    x86_64)
	EXTRA_FLAGS="${EXTRA_FLAGS} -march=x86-64-v3"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DBUILD_STATIC=0 -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS="-DBUILD_STATIC=1"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
	-DEXTRA_FLAGS="${EXTRA_FLAGS}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build --clean-first -j "${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
