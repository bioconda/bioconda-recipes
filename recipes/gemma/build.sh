#!/bin/bash
set -eu

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -DHAVE_INLINE -pthread -Wall -std=c++14"

mkdir -p "${PREFIX}/bin"

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

sed -i.bak "s|-lgsl -lz|-L${PREFIX}/lib -lgsl -lz|" Makefile
rm -f *.bak

make GCC_FLAGS="${CXXFLAGS}" release

install -v -m 0755 bin/gemma "${PREFIX}/bin"
