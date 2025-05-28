#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LC_ALL="en_US.UTF-8"

# use newer config.guess and config.sub that support osx-arm64
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* cimfomfa/
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* autofoo/

cd cimfomfa
autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" --disable-shared \
	--enable-silent-rules --disable-dependency-tracking --disable-option-checking
make -j"${CPU_COUNT}"
make install
make clean

cd ..
autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" --enable-rcl \
	--enable-silent-rules --disable-dependency-tracking --disable-option-checking
make -j"${CPU_COUNT}"
make install
make clean

# Add back in the mcl/blast scripts.
# Remove this once the next release re-incorporates them.
# See https://github.com/micans/mcl/discussions/25
install -v -m 0755 ${RECIPE_DIR}/scripts/mc* "${PREFIX}/bin"
