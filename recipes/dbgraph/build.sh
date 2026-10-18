#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

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

mkdir -p "$PREFIX/bin"

cd Graph2Pro

make clean
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 DBGraph2Pro DBGraphPep2Pro "$PREFIX/bin"
