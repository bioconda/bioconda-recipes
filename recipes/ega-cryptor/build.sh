#!/usr/bin/env bash
set -e -x
# set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -Rf * $outdir/
mv $outdir/EGA-Cryptor-$PKG_VERSION/ega-cryptor-$PKG_VERSION.jar $outdir/ega-cryptor.jar
cp -f $RECIPE_DIR/ega-cryptor.py $outdir/ega-cryptor
chmod +x $outdir/ega-cryptor
ln -sf $outdir/ega-cryptor $PREFIX/bin