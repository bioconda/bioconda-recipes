#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/pia.sh $outdir/pia
ln -s $outdir/pia $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pia"
