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
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

mkdir -p "${PREFIX}/bin"
mkdir -p bin/

C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make CC="${CXX}" GSL_PATH="${PREFIX}/"

make install BIN_INSTALL="${PREFIX}/bin/"

mv ${PREFIX}/bin/nemoage* ${PREFIX}/bin/nemoage
