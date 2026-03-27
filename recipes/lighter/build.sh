#!/bin/bash

mkdir -p ${PREFIX}/bin

case $(uname -m) in
	aarch64)
		export CXXFLAGS="${CXXFLAGS} -Wno-narrowing"
		;;
	*)
		export CXXFLAGS="${CXXFLAGS}"
		;;
esac

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

chmod 0755 lighter
cp -f lighter ${PREFIX}/bin
