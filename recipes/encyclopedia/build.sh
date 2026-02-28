#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
ln -s  encyclopedia-$PKG_VERSION-executable.jar encyclopedia-executable.jar
cp -R * $outdir/
cp $RECIPE_DIR/encyclopedia.py $outdir/EncyclopeDIA
ls -l $outdir
ln -s $outdir/EncyclopeDIA $PREFIX/bin
chmod 0755 "${PREFIX}/bin/EncyclopeDIA"
