#!/bin/bash
# Build file is copied from VarScan
set -eu -o pipefail

jar_file="Biopet-0.8.0-26269612.jar"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp $jar_file $outdir/$jar_file
cp $RECIPE_DIR/biopet.py $outdir/biopet
ln -s $outdir/biopet $PREFIX/bin
