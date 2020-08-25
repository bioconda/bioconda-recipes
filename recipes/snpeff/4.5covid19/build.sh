#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"
#cd snpEff/ # for the 4.5covid19 release, snpEff does not reside in a subdir within the zip
# data/ should be omitted once databases are available on sourceforge for v4_5
# check here: https://sourceforge.net/projects/snpeff/files/databases/
mv scripts/ data/ snpEff.config snpEff.jar "$outdir/" 
cp "$RECIPE_DIR/snpeff.py" "$outdir/snpEff"
chmod +x "$outdir/snpEff"

ln -s "$outdir/snpEff" "$PREFIX/bin"
