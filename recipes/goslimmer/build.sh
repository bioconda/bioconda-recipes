#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/goslimmer.py $outdir/goslimmer
ls -l $outdir
ln -s $outdir/goslimmer $PREFIX/bin
chmod 0755 "${PREFIX}/bin/goslimmer"
