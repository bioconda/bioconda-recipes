#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
mv $outdir/rdp_classifier-$PKG_VERSION.jar $outdir/rdp_classifier.jar
cp $RECIPE_DIR/rdp_classifier.sh $outdir/rdp_classifier
chmod +x $outdir/rdp_classifier

ln -s $outdir/rdp_classifier $PREFIX/bin
