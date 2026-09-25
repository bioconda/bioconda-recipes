#!/bin/bash

set -xe

cp -rf $BUILD_PREFIX/share/gnuconfig/config.* config/

export M4="${BUILD_PREFIX}/bin/m4"
export GTEXTUTILS_CFLAGS="-I ${PREFIX}/include/gtextutils"
export GTEXTUTILS_LIBS="${PREFIX}/lib/libgtextutils.a"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -I${PREFIX}/include -Wall -Wno-implicit-fallthrough -Wno-unused-but-set-variable"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
sed -i.bak 's/#pragma pack(1)//g' src/libfastx/fastx.h
sed -i.bak '88,90d;58d' src/fastx_artifacts_filter/fastx_artifacts_filter.c
sed -i.bak 's/ -Werror//' configure.ac
rm -rf src/libfastx/*.bak
rm -rf src/fastx_artifacts_filter/*.bak
rm -rf *.bak

if [[ "$(uname)" == "Darwin" ]]; then
	export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
	export MACOSX_DEPLOYMENT_TARGET="10.15"
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi

./reconf
./configure --prefix="${PREFIX}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
 	--enable-debug=no --enable-static --enable-all-static \
  	--disable-shared --disable-option-checking
make -j"${CPU_COUNT}"
make install
