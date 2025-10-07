#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -Rf * $outdir/
cp -f $RECIPE_DIR/peptide-shaker.py $outdir/peptide-shaker
ln -sf $outdir/peptide-shaker $PREFIX/bin
chmod 0755 "${PREFIX}/bin/peptide-shaker"
ls $outdir/resources
chmod -R a+rw $outdir/resources/
