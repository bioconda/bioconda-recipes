#!/bin/sh

progDir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $progDir
mv bin $progDir

mkdir -p $PREFIX/bin
ln -s $progDir/bin/IRFinder $PREFIX/bin/IRFinder
