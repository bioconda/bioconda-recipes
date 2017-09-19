#!/bin/bash

set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
gzip -d mhap-2.1.1.jar.gz
cp -R * $outdir/
cp $RECIPE_DIR/mhap.py $outdir/mhap
ls -l $outdir
ln -s $outdir/mhap $PREFIX/bin
chmod 0755 "${PREFIX}/bin/mhap"
