#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R *.jar $outdir/pilon.jar
cp $RECIPE_DIR/pilon.py $outdir/pilon
ls -l $outdir
ln -s $outdir/pilon $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pilon"
