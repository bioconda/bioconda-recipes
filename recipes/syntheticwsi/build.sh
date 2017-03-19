#!/bin/bash
set -eu -o pipefail

ant -buildfile syntheticwsi.xml

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/syntheticwsi.py $outdir/syntheticwsi
ls -l $outdir
ln -s $outdir/syntheticwsi $PREFIX/bin
chmod 0755 "${PREFIX}/bin/syntheticwsi"
