#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"
mv $SRC_DIR/${PKG_NAME}.jar "$outdir/"
cp "$RECIPE_DIR/bazam.sh" "$outdir/bazam"
chmod +x "$outdir/bazam"
ln -s "$outdir/bazam" "$PREFIX/bin"
