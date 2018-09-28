#!/bin/bash

echo $PREFIX
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp  ibdne.04Sep15.e78.jar $outdir/ibdne.jar
cp $RECIPE_DIR/ibdne $outdir/
chmod +x $outdir/ibdne
ln -s $outdir/ibdne $PREFIX/bin

