#!/bin/bash

mkdir -p $PREFIX/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"

cd cimfomfa
autoupdate
autoreconf -if
./configure --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--disable-shared
make -j"${CPU_COUNT}"
make install
make clean

cd ..
autoupdate
./configure --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--enable-rcl
make -j"${CPU_COUNT}"
make install
make clean

# Add back in the mcl/blast scripts.
# Remove this once the next release re-incorporates them.
# See https://github.com/micans/mcl/discussions/25
cp -rf $RECIPE_DIR/scripts/mc* $PREFIX/bin/
