#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir

cp *.jar $outdir
cp $RECIPE_DIR/varna.py $outdir

ln -s $outdir/varna.py $PREFIX/bin/varna

chmod 0755 $PREFIX/bin/varna





