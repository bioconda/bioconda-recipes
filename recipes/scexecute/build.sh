#!/bin/sh

mkdir -p $PREFIX/$PKG_NAME
cp -r $SRC_DIR/* $PREFIX/$PKG_NAME
for a in $PREFIX/$PKG_NAME/bin/*; do
  b=`basename $a`
  ( cd $PREFIX/bin; ln -s ../$PKG_NAME/bin/$b )
done
