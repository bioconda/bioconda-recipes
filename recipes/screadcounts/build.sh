#!/bin/bash

TARGET=share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/$TARGET/bin
mkdir -p $PREFIX/bin
cp -r * $PREFIX/$TARGET
rm -rf $PREFIX/$TARGET/data
chmod -R a+rX $PREFIX/$TARGET
chmod -R a+rx $PREFIX/$TARGET/bin/
cd $PREFIX/bin
ln -s ../$TARGET/bin/* .
