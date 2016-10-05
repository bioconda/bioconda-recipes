#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/qorts.py $outdir/qorts
ls -l $outdir
ln -s $outdir/qorts $PREFIX/bin
chmod 0755 "${PREFIX}/bin/qorts"
