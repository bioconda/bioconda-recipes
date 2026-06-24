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

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
