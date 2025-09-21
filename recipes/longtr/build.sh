#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3 -g -D__STDC_LIMIT_MACROS -D_FILE_OFFSET_BITS=64 -std=c++0x -DMACOSX -pthread"

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

make LongTR DenovoFinder PhasingChecker -j"${CPU_COUNT}"

install -v -m 0755 LongTR DenovoFinder PhasingChecker "${PREFIX}/bin"
