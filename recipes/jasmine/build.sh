#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp *.jar $outdir/
cp $RECIPE_DIR/jasmine.py $outdir/jasmine
ln -s $outdir/jasmine $PREFIX/bin
chmod 0755 "${PREFIX}/bin/jasmine"
