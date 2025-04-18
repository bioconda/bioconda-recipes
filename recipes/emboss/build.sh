#!/bin/bash

# use newer config.guess and config.sub that support osx-arm64
cp ${RECIPE_DIR}/config.* .


# Regenerate configure to fix flat namespace errors on macOS 11+
autoreconf -fvi
./configure \
    --prefix=$PREFIX \
    --without-x \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-64 \
    --with-thread 

make -j ${CPU_COUNT}
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
