#!/bin/bash
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin
cp  *jar $target/.
mv $target/qsignature-$PKG_VERSION.jar $target/qsignature.jar
cp $RECIPE_DIR/qsignature.sh $target/qsignature
ln -s $target/qsignature $PREFIX/bin
chmod 0755 $PREFIX/bin/qsignature


