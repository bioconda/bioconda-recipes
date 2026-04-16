#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++17"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"

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

if [[ "$target_platform" == "osx-64" || "$target_platform" == "osx-arm64" ]]; then
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    echo "-isysroot is ${SDKROOT}"
    export CFLAGS="${CFLAGS} -isysroot ${SDKROOT}"
    export LDFLAGS="${LDFLAGS} -isysroot ${SDKROOT}"
fi

${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir
