#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

mkdir -p "$PREFIX/bin"

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP \$(DEFAULT_FLAGS) ${LDFLAGS}"

install -v -m 0755 age_align "$PREFIX/bin"
