#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/kinamine_y_shaker.py $outdir/KinamineY-shaker
ls -l $outdir
ln -s $outdir/KinamineY-shaker $PREFIX/bin
chmod 0755 "${PREFIX}/bin/KinamineY-shaker"
