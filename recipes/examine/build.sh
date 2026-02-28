#!/bin/bash
set -eu -o pipefail

mvn install

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp eXamine.jar $outdir/
cp $RECIPE_DIR/examine.py $outdir/examine

ln -s $outdir/examine $PREFIX/bin
chmod 0755 "${PREFIX}/bin/examine"
