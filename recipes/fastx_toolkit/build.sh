#!/bin/bash

set -xe

cp -rf $BUILD_PREFIX/share/gnuconfig/config.* config/

export GTEXTUTILS_CFLAGS="-I $PREFIX/include/gtextutils"
export GTEXTUTILS_LIBS="$PREFIX/lib/libgtextutils.a"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wall -Wno-implicit-fallthrough -Wno-unused-but-set-variable"
sed -i.bak 's/#pragma pack(1)//g' src/libfastx/fastx.h

if [[ "$(uname)" == "Darwin" ]]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    MACOSX_DEPLOYMENT_TARGET=10.15
    CXXFLAGS="${CXXFLAGS} -std=c++14 -stdlib=libc++"
fi

autoreconf -if

./configure --prefix="$PREFIX" CC="$CC" CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
make -j"${CPU_COUNT}"
make install
