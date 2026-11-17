#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak 's|-lrt||' Makefile
	rm -f *.bak
fi

make clean CXX="${CXX}"

CXXFLAGS="-c $CXXFLAGS" make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 skewer "${PREFIX}/bin"
