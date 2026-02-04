#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/GeMoMa.py $outdir/GeMoMa
ls -l $outdir
ln -s $outdir/GeMoMa $PREFIX/bin/GeMoMa
chmod 0755 "${PREFIX}/bin/GeMoMa"