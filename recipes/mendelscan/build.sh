#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp MendelScan.v1.2.2.jar $outdir/
cp $RECIPE_DIR/mendelscan $outdir/
chmod +x $outdir/mendelscan
ln -s $outdir/mendelscan $PREFIX/bin

