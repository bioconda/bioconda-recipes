#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
mv $outdir/trimmomatic-$PKG_VERSION.jar $outdir/trimmomatic.jar
cp $RECIPE_DIR/trimmomatic.py $outdir/trimmomatic
chmod +x $outdir/trimmomatic

ln -s $outdir/trimmomatic $PREFIX/bin
