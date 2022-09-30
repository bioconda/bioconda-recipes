#!/bin/bash
mkdir -p $PREFIX/bin
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
cp -r * $outdir/
cp "$RECIPE_DIR/rawtools.sh" "$outdir/rawtools.sh"
chmod +x "$outdir/rawtools.sh"
ln -s "$outdir/rawtools.sh" "$PREFIX/bin"
