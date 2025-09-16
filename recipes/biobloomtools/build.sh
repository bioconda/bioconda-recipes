#!/bin/bash
set -xe

export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-unused-parameter -Wno-stringop-overflow"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-unused-parameter -Wno-stringop-overflow"

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

./configure --prefix="${PREFIX}" \
	--with-sparsehash="${PREFIX}" \
	--with-sdsl="${PREFIX}" \
	--disable-dependency-tracking --disable-silent-rules \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}"
make install
