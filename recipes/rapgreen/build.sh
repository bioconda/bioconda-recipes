#!/bin/bash

rapgreen=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $rapgreen
mkdir -p $PREFIX/bin
cp -R * $rapgreen/
cp $RECIPE_DIR/test_rapgreen $rapgreen/rap-green
ln -s $rapgreen/rapgreen $PREFIX/bin
chmod 0755 "${PREFIX}/bin/rap-green"
ls $rapgreen/resources
cmod -R a+rw $rapgreen/resources/