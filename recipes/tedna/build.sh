#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' makefile && rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' makefile && rm -f *.bak
	;;
esac

# make
make -j"${CPU_COUNT}"

# copy binary
install -v -m 0755 ./tedna "$PREFIX/bin"
