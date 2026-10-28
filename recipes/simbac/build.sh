#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case $(uname -m) in
    aarch64)
	export ARCH="-march=armv8-a"
	;;
    arm64)
	export ARCH="-march=armv8.4-a"
	;;
    x86_64)
	export ARCH="-march=x86-64-v3"
	;;
esac

mkdir -p "$PREFIX/bin"

${CXX} *.cpp -lgsl -lgslcblas -lm ${ARCH} -O3 -lstdc++ -L$PREFIX/lib -I$PREFIX/include -o $PREFIX/bin/SimBac
