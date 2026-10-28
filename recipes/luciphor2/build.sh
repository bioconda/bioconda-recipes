#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp luciphor*jar $outdir/luciphor2.jar
cp $RECIPE_DIR/luciphor2.sh $outdir/luciphor2
ln -s $outdir/luciphor2 $PREFIX/bin
chmod 0755 "$outdir/luciphor2"
