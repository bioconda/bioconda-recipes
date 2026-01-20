#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp ./sequnwinder_v0.1.4.jar $outdir
cp $RECIPE_DIR/sequnwinder.sh $outdir/sequnwinder
chmod +x $outdir/sequnwinder
ln -s $outdir/sequnwinder $PREFIX/bin
