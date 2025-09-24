#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -Wall -pthread -Wno-misleading-indentation -Wno-maybe-uninitialized"

sed -i.bak 's|g++|$(CXX)|' makefile
sed -i.bak 's|-lpthread|-march=x86-64-v3|' makefile

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' makefile
	;;
esac

rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 karect "${PREFIX}/bin"
