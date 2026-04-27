#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "$PREFIX/bin/bin"

sed -i.bak 's|CC=g++|CC=$(CXX)|' Makefile

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++11 -O3|-std=c++14 -O3 -march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-std=c++11 -O3|-std=c++14 -O3 -march=armv8.4-a|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-std=c++11 -O3|-std=c++14 -O3 -march=x86-64-v3|' Makefile
	;;
esac

chmod +x gflags.py
2to3 -w draw_circular_plot linearfold

rm -f *.bak

# Build
make -j"${CPU_COUNT}"

# Install
install -v -m 0755 bin/* "$PREFIX/bin/bin"
install -v -m 0755 linearfold AUTHORS draw_circular_plot gflags.py testcons "$PREFIX/bin"
