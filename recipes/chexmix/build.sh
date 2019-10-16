#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp ./chexmix_v0.4.jar $outdir
cp $RECIPE_DIR/chexmix.sh $outdir/chexmix
chmod +x $outdir/chexmix
ln -s $outdir/chexmix $PREFIX/bin
