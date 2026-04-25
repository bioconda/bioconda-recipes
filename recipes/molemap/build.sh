#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

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

case $(uname -s) in
    Darwin)
    sed -i.bak "s|g++|${CXX}|" Makefile
		sed -i.bak 's|-lrt||g' Makefile
    rm -f *.bak ;;
esac

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT}"

install -v -m 0755 molemap "${PREFIX}/bin"
