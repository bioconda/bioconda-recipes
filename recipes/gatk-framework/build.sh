#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
cp $RECIPE_DIR/gatk-framework $outdir/
chmod +x $outdir/gatk-framework

ln -s $outdir/gatk-framework $PREFIX/bin
