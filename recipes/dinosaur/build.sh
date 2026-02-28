#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/dinosaur.py $outdir/dinosaur
ls -l $outdir
ln -s $outdir/dinosaur $PREFIX/bin
chmod 0755 "${PREFIX}/bin/dinosaur"
