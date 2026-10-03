#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
mv $outdir/ClusterPicker_$PKG_VERSION.jar $outdir/cluster-picker.jar
cp $RECIPE_DIR/cluster-picker.sh $outdir/cluster-picker
chmod +x $outdir/cluster-picker

ln -s $outdir/cluster-picker $PREFIX/bin
