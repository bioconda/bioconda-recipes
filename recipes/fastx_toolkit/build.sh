#!/bin/bash

set -xe

cp -rf $BUILD_PREFIX/share/gnuconfig/config.* config/

export GTEXTUTILS_CFLAGS="-I ${PREFIX}/include/gtextutils"
export GTEXTUTILS_LIBS="${PREFIX}/lib/libgtextutils.a"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 --disable-dependency-tracking --enable-silent-rules -I${PREFIX}/include -Wall -Wno-implicit-fallthrough -Wno-unused-but-set-variable"
export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
sed -i.bak 's/#pragma pack(1)//g' src/libfastx/fastx.h
rm -rf src/libfastx/*.bak

if [[ "$(uname)" == "Darwin" ]]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    export MACOSX_DEPLOYMENT_TARGET="10.15"
    export CXXFLAGS="${CXXFLAGS} -std=c++14 -stdlib=libc++"
fi

autoreconf -if

./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
