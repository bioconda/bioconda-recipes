#!/bin/bash

export OS=$(uname -s | tr '[:upper:]' '[:lower:]')

make

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cp thesias.jar $outdir/
cp $RECIPE_DIR/THESIAS.py $outdir/THESIAS
ln -s $outdir/THESIAS $PREFIX/bin
cp libthesiaslib.so.0 $PREFIX/lib
ln -s $PREFIX/lib/libthesiaslib.so.0 $PREFIX/lib/libthesiaslib.so
