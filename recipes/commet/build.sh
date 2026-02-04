#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
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

2to3 -wn Commet.py

# installation
make CC="$CXX" CFLAGS="$CXXFLAGS -Iinclude -L${PREFIX}/lib ${LDFLAGS}"

# copy binaries and scripts
install -v -m 0755 bin/* Commet.py dendro.R heatmap.r "${PREFIX}/bin"
