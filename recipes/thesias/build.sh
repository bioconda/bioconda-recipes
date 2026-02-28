#!/bin/bash

make

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mv thesias.jar $outdir/
chmod +x $RECIPE_DIR/THESIAS.py
mv $RECIPE_DIR/THESIAS.py $outdir/THESIAS
ln -s $outdir/THESIAS $PREFIX/bin/THESIAS
mv libthesiaslib.so.0 $PREFIX/lib/libthesiaslib.so
