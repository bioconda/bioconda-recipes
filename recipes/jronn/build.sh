#!/bin/bash
set -eu

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin

PKG_VERSION="$PKG_VERSION" gradle jar
cp build/libs/jronn-$PKG_VERSION.jar $OUTDIR/
sed "s/{{PKG_VERSION}}/$PKG_VERSION/" $RECIPE_DIR/jronn.sh > $OUTDIR/jronn
ln -s $OUTDIR/jronn $PREFIX/bin/jronn
chmod +x $PREFIX/bin/jronn
