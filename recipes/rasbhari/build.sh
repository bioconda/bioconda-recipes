#!/bin/bash
set -eux

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++11|-std=c++14 -march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-std=c++11|-std=c++14 -march=armv8.4-a|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-std=c++11|-std=c++14 -march=x86-64-v3|' Makefile
	;;
esac

rm -f *.bak

make -j"${CPU_COUNT}" CC="${CXX}"

install -v -m 0755 rasbhari "${PREFIX}/bin"
