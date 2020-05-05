#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"
#cd snpEff/ # for the 4.5covid19 release, snpEff does not reside in a subdir within the zip
mv scripts/ snpEff.config snpEff.jar "$outdir/"
cp "$RECIPE_DIR/snpeff.py" "$outdir/snpEff"
chmod +x "$outdir/snpEff"

ln -s "$outdir/snpEff" "$PREFIX/bin"
