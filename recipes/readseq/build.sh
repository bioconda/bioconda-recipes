#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"
mv $SRC_DIR/${PKG_NAME}.jar "$outdir/"
cp "$RECIPE_DIR/readseq.sh" "$outdir/readseq"
chmod +x "$outdir/readseq"
ln -s "$outdir/readseq" "$PREFIX/bin"
