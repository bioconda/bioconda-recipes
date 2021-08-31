#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp *.tree images/* lib/* $outdir/
cp $RECIPE_DIR/figtree.py $outdir/figtree
ls -l $outdir
ln -s $outdir/figtree $PREFIX/bin
chmod 0755 "${PREFIX}/bin/figtree"
