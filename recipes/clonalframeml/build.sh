#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

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

cd src

make CC="$CXX"

install -v -m 0755 ClonalFrameML "${PREFIX}/bin"
