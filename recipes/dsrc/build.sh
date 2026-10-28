#!/bin/bash
set -xe

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

if [[ "$(uname -s)" == "Darwin" ]]; then
	DEP_LIBS="${LDFLAGS}" make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -f Makefile.osx bin
else
	DEP_LIBS="${LDFLAGS}" make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -f Makefile.c++11 bin
fi

install -v -m 0755 bin/dsrc "${PREFIX}/bin"
