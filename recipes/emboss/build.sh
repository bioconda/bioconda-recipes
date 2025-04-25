#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

# use newer config.guess and config.sub that support osx-arm64
cp ${RECIPE_DIR}/config.* .

# Regenerate configure to fix flat namespace errors on macOS 11+
autoreconf -fvi
./configure \
    --prefix="${PREFIX}" \
    --without-x \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-64 \
    --with-thread 

make -j"${CPU_COUNT}"
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
