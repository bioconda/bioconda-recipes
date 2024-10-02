#!/bin/bash
set -e -x
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME
mkdir -p $PREFIX/bin
cp -Rf * $outdir/
mv $outdir/ega-cryptor-$PKG_VERSION.jar $outdir/ega-cryptor.jar
cp -f $RECIPE_DIR/ega-cryptor.py $outdir/ega-cryptor
ln -sf $outdir/ega-cryptor $PREFIX/bin
chmod 0755 "${PREFIX}/bin/ega-cryptor"

