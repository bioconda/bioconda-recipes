#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
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

install -d "${PREFIX}/bin"

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	CP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	-j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
