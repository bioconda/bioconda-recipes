#!/bin/bash
target=$PREFIX/share/java/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin
cp  *jar $target/.
mv $target/pilon-$PKG_VERSION.jar $target/pilon.jar
cp $RECIPE_DIR/pilon.sh $target/pilon
ln -s $target/pilon $PREFIX/bin
chmod 0755 $PREFIX/bin/pilon


