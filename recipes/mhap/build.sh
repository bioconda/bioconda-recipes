#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

gzip -d mhap-$PKG_VERSION.jar.gz
cp mhap-$PKG_VERSION.jar $outdir/mhap.jar
cp $RECIPE_DIR/mhap.py $outdir/mhap
chmod +x $outdir/mhap
ln -s $outdir/mhap $PREFIX/bin/mhap
