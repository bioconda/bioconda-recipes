#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
#cp -R * $outdir/
cp target/LRScaf-1.1.5.jar $outdir/
cp $RECIPE_DIR/lrscaf.py $outdir/lrscaf

ln -s $outdir/lrscaf $PREFIX/bin
chmod 0755 "${PREFIX}/bin/lrscaf"

