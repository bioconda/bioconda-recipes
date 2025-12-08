#!/bin/bash
set -eu

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin

cp $SRC_DIR/compbio-conservation-$PKG_VERSION.jar $OUTDIR/compbio-conservation.jar
cp $RECIPE_DIR/aacon.sh $OUTDIR/aacon
ln -s $OUTDIR/aacon $PREFIX/bin/aacon
chmod +x $PREFIX/bin/aacon
