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
	sed -i.bak 's|-msse4.2 -mpclmul -march=native|-march=armv8-a|' bonsai/clhash/Makefile
	sed -i.bak 's|-march=native|-march=armv8-a|' bonsai/Makefile
	sed -i.bak 's|-march=native|-march=armv8-a|' bonsai/python/Makefile
	sed -i.bak 's|-march=native|-march=armv8-a|' bonsai/hll/Makefile
	;;
    arm64)
	sed -i.bak 's|-march=native|-march=armv8.4-a|' Makefile
	sed -i.bak 's|-msse4.2 -mpclmul -march=native|-march=armv8.4-a|' bonsai/clhash/Makefile
	sed -i.bak 's|-march=native|-march=armv8-a|' bonsai/Makefile
	sed -i.bak 's|-march=native|-march=armv8-a|' bonsai/python/Makefile
	sed -i.bak 's|-march=native|-march=armv8-a|' bonsai/hll/Makefile
	;;
    x86_64)
	sed -i.bak 's|-march=native|-march=x86-64-v3|' Makefile
	sed -i.bak 's|-msse4.2 -mpclmul -march=native|-march=x86-64-v3|' bonsai/clhash/Makefile
	sed -i.bak 's|-march=native|-march=x86-64-v3|' bonsai/Makefile
	sed -i.bak 's|-march=native|-march=x86-64-v3|' bonsai/python/Makefile
	sed -i.bak 's|-march=native|-march=x86-64-v3|' bonsai/hll/Makefile
	;;
esac

sed -i.bak "s/ -lzstd//g" Makefile
sed -i.bak 's|ar r|$(AR) rcs|' Makefile
sed -i.bak 's|-std=c99|-std=c11|' bonsai/clhash/Makefile
rm -rf *.bak

make CC="${CC}" CXX="${CXX}" INCPLUS="-I${PREFIX}/include" EXTRA_LD="-L${PREFIX}/lib" -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
