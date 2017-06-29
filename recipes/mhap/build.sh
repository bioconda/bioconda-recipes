#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp mhap-2.0.jar $outdir/
cp $RECIPE_DIR/mhap $outdir/
chmod +x $outdir/mhap
ln -s $outdir/mhap $PREFIX/bin

