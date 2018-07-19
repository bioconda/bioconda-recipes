#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/gbsx $outdir/gbsx
ls -l $outdir
ln -s $outdir/gbsx $PREFIX/bin
chmod 0755 "${PREFIX}/bin/gbsx"
