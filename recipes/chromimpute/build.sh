#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin

mv ChromImpute.jar $outdir/
chmod +x $RECIPE_DIR/ChromImpute.sh
mv $RECIPE_DIR/ChromImpute.sh $outdir/ChromImpute
ln -s $outdir/ChromImpute $PREFIX/bin/ChromImpute
