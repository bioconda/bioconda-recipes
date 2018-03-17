#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp VarScan*jar $outdir/VarScan.jar
cp $RECIPE_DIR/varscan.sh $outdir/varscan
ln -s $outdir/varscan $PREFIX/bin
