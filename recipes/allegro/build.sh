#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++03"
export LC_ALL=C

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

mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/

cd src/
autoreconf -if -I .
cd ..

./configure

sed -i.bak 's|CFLAGS = -g -O3|CFLAGS = -g -O3 -Wno-implicit-function-declaration|' src/cudd-2.4.0/cudd/Makefile
sed -i.bak 's|CFLAGS = -g -O3|CFLAGS = -g -O3 -Wno-implicit-function-declaration|' src/cudd-2.4.0/Makefile
sed -i.bak 's|assertinternal(finite|assertinternal(isfinite|' src/*.cc
sed -i.bak 's|if (!finite|if (!isfinite|' src/*.cc
rm -f src/*.bak

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 allegro "$PREFIX/bin"
