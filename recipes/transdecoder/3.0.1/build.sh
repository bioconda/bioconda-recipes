#!/bin/bash

# install in opt/
mkdir -p $PREFIX/opt/
cp -r $SRC_DIR $PREFIX/opt/$PKG_NAME

# symlink to binaries
mkdir -p $PREFIX/bin/
ln -s $PREFIX/opt/$PKG_NAME/TransDecoder.Predict $PREFIX/bin/
ln -s $PREFIX/opt/$PKG_NAME/TransDecoder.LongOrfs $PREFIX/bin/
ln -s $PREFIX/opt/$PKG_NAME/util/*.pl $PREFIX/bin/
