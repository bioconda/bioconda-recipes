#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/umicollapse.py $outdir/umicollapse
ln -s $outdir/umicollapse $PREFIX/bin
chmod 0755 "${PREFIX}/bin/umicollapse"