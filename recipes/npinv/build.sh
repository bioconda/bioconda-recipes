#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/npinv.py $outdir/npinv
ls -l $outdir
ln -s $outdir/npinv $PREFIX/bin
chmod 0755 "${PREFIX}/bin/npinv"
