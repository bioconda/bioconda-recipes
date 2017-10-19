#!/bin/bash

./configure --prefix=$SRC_DIR
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/src/clustalo $PREFIX/bin/$PKG_NAME
chmod +x $PREFIX/bin/$PKG_NAME
