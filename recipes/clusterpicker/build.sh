#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
mv release/ClusterPicker_$PKG_VERSION.jar $outdir/cluster-picker.jar
# create both cluster-picker and ClusterPicker wrapper scripts to follow bioconda
# historical name and Brew convention
cp $RECIPE_DIR/cluster-picker.sh $outdir/cluster-picker
cp $RECIPE_DIR/cluster-picker.sh $outdir/ClusterPicker
chmod +x $outdir/cluster-picker
chmod +x $outdir/ClusterPicker

ln -s $outdir/cluster-picker $PREFIX/bin
ln -s $outdir/ClusterPicker $PREFIX/bin
