#!/bin/bash
set -eu -o pipefail
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/jgoslin.py $outdir/jgoslin
ls -l $outdir
ln -s $outdir/jgoslin $PREFIX/bin
echo "Contents of '$outdir'"
chmod 0755 "${PREFIX}/bin/jgoslin"
