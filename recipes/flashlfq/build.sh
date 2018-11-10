#!/bin/bash
mkdir -p $PREFIX/bin
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
cp -r * $outdir/
cp "$RECIPE_DIR/FlashLFQ.sh" "$outdir/FlashLFQ"
chmod +x "$outdir/FlashLFQ"
ln -s "$outdir/FlashLFQ" "$PREFIX/bin"

