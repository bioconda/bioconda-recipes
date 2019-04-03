#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/PepGenome.py $outdir/PepGenome
ls -l $outdir
ln -s $outdir/PepGenome $PREFIX/bin
chmod 0755 "${PREFIX}/bin/PepGenome"
