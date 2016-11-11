#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

mv ./multigps_v0.5.jar $PREFIX/bin
cp $RECIPE_DIR/multigps.sh $outdir/multigps
ln -s $outdir/multigps $PREFIX/bin
chmod +x "${PREFIX}/bin/multigps"
