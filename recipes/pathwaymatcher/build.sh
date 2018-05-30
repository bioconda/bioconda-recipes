#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
cp $RECIPE_DIR/pathwaymatcher.py $outdir/pathwaymatcher
chmod +x $outdir/pathwaymatcher

ln -s $outdir/pathwaymatcher $PREFIX/bin
