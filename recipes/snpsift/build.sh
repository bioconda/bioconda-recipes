#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"
cd snpEff/
cp -R SnpSift.jar "$outdir/"
cp $RECIPE_DIR/snpsift.py $outdir/SnpSift
chmod +x "$outdir/SnpSift"

ln -s "$outdir/SnpSift" "$PREFIX/bin"
