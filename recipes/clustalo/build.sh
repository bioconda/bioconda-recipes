#!/bin/bash

./configure --prefix=$SRC_DIR
make
make install

mkdir -p $PREFIX/bin
cp $SRC_DIR/bin/clustal* $PREFIX/bin/$PKG_NAME
chmod +x $PREFIX/bin/$PKG_NAME
