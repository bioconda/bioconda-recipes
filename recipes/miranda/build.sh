#!/bin/bash
set -e

export CFLAGS="${CFLAGS} -O3 -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# use newer config.guess and config.sub that support linux-aarch64
cp -f $BUILD_PREFIX/share/gnuconfig/config.* .


./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
