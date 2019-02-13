#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R dist/* $outdir/
cp $RECIPE_DIR/pantools.py $outdir/pantools
ls -l $outdir
ln -s $outdir/pantools.jar $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pantools"
