#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R $SRC_DIR/TOPAS-${PKG_VERSION}.jar  $outdir/TOPAS.jar
cp $RECIPE_DIR/topas.py $outdir/topas 
ls -l $outdir
ln -s $outdir/topas $PREFIX/bin
chmod 0755 ${PREFIX}/bin/topas
