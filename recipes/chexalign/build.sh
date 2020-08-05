#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp ./chexalign_v0.11.jar $outdir
cp $RECIPE_DIR/chexalign.sh $outdir/chexalign
chmod +x $outdir/chexalign
ln -s $outdir/chexalign $PREFIX/bin
