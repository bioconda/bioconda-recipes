#!/bin/bash

set -e -u -x

export M4="${BUILD_PREFIX}/bin/m4"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# use newer config.guess and config.sub that support osx-arm64
cp -rf $BUILD_PREFIX/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" \
	--with-gsl="${PREFIX}" --disable-option-checking \
	--enable-threads --enable-mpi CC="${CC}" \
	CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"
make -j"${CPU_COUNT}"
make install
(cd "${SRC_DIR}/easel" && make install -j"${CPU_COUNT}")

# keep easel lib for other rcipes (e.g sfld)
mkdir -p $PREFIX/share
rm -rf ${SRC_DIR}/easel/miniapps
cp -rf ${SRC_DIR}/easel $PREFIX/share/
