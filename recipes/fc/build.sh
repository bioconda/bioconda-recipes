#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-implicit-function-declaration"

mkdir -p ${PREFIX}/bin

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

make CXX="${CXX}" INCLUDES="-I$PREFIX/include" CXXFLAGS="${CXXFLAGS}" -j1

install -v -m 0755 bin/fc-virus ${PREFIX}/bin
