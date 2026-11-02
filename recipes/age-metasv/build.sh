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
esac

sed -i.bak -E '/^#pragma omp shared\(thread1_i2,thread2_i2\);?$/d' AGEaligner.cpp
rm -f *.bak

mkdir -p "$PREFIX/bin"

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP \$(DEFAULT_FLAGS) ${LDFLAGS}"

install -v -m 0755 age_align "$PREFIX/bin"
