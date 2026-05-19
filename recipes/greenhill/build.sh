#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64|-march=armv8-a|' src/Makefile && rm -f src/*.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64|-march=armv8.4-a|' src/Makefile && rm -f src/*.bak
	;;
esac

cd src

make CXX="$CXX" -j"${CPU_COUNT}"

install -v -m 0755 greenhill "$PREFIX/bin"
