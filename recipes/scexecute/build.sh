#!/bin/sh

mkdir -p $PREFIX/$PKG_NAME
cp -r $SRC_DIR/* $PREFIX/$PKG_NAME
for a in $PREFIX/$PKG_NAME/bin/*; do
  b=`basename $a`
  ln -s $a $PREFIX/bin/$b
done
