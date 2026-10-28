#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp ./multigps_v0.74.jar $outdir
cp $RECIPE_DIR/multigps.sh $outdir/multigps
chmod +x $outdir/multigps
ln -s $outdir/multigps $PREFIX/bin
