#!/bin/bash
mkdir -p $PREFIX/bin
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir/runtimes
if [[ "$(uname)" == "Linux" ]]; then 
cp -rp runtimes/linux-x64 $outdir/runtimes/
fi
rm -r runtimes
cp -r * $outdir/
cp "$RECIPE_DIR/MetaMorpheus.sh" "$outdir/MetaMorpheus"
chmod +x "$outdir/MetaMorpheus"
ln -s "$outdir/MetaMorpheus" "$PREFIX/bin"
