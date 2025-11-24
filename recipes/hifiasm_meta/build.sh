#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-lpthread|-pthread|' Makefile
case $(uname -m) in
    x86_64)
	sed -i.bak 's|-msse4.2 -mpopcnt|-msse4.2 -mpopcnt -march=x86-64-v3|' Makefile
  ;;
    aarch64)
	sed -i.bak 's|-msse4.2 -mpopcnt|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-msse4.2 -mpopcnt|-march=armv8.4-a|' Makefile
	;;
esac
rm -f *.bak

make INCLUDES="-I$PREFIX/include" CPPFLAGS="${CPPFLAGS}" CXXFLAGS="${CXXFLAGS}" CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 hifiasm_meta "$PREFIX/bin"
