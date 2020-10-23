#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp opsin*jar $outdir/opsin.jar
cp $RECIPE_DIR/opsin.sh $outdir/opsin
ls -l $outdir
ln -s $outdir/opsin $PREFIX/bin
chmod 0755 "${PREFIX}/bin/opsin"
