#!/bin/bash

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

pushd bonsai
rm -rf zstd
git clone --recursive --single-branch --branch dev https://github.com/facebook/zstd
pushd zstd
make CC="${CC}" lib -j"${CPU_COUNT}" && mv lib/libzstd.a ..
popd
popd

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=native|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=native|-march=armv8.4-a|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-march=native|-march=x86-64-v3|' Makefile
	;;
esac

sed -i.bak "s/ -lzstd//g" Makefile
sed -i.bak 's|ar r|$(AR) rcs|' Makefile
rm -rf *.bak

make CC="${CC}" CXX="${CXX}" INCPLUS="-I${PREFIX}/include" EXTRA_LD="-L${PREFIX}/lib" -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
