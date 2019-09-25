#!/bin/bash
set -eu -o pipefail

outdir=${PREFIX}/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo $outdir
mkdir -p $outdir
mkdir -p ${PREFIX}/bin
cp -R * $outdir/
cp $RECIPE_DIR/multivcfanalyzer.py $outdir/multivcfanalyzer
ln -s $outdir/multivcfanalyzer $PREFIX/multivcfanalyzer
chmod 0755 ${PREFIX}/bin/multivcfanalyzer
