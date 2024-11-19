#!/usr/bin/env bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
ln -s  ega-cryptor-$PKG_VERSION.jar ega-cryptor.jar
cp -R * $outdir/
cp $RECIPE_DIR/ega-cryptor.py $outdir/ega-cryptor
ln -s $outdir/ega-cryptor $PREFIX/bin
chmod 0755 "${PREFIX}/bin/ega-cryptor"