#!/bin/bash
set -eu

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin

VDIR=`ls -d $SRC_DIR/Canvas-*_x64`
cp $RECIPE_DIR/Canvas.sh $VDIR/Canvas
chmod +x $VDIR/Canvas
cp $RECIPE_DIR/EvaluateCNV.sh $VDIR/Tools/EvaluateCNV/EvaluateCNV
chmod +x $VDIR/Tools/EvaluateCNV/EvaluateCNV

cp -r $VDIR/* $OUTDIR
ln -s $OUTDIR/Canvas $PREFIX/bin
ln -s $OUTDIR/Tools/EvaluateCNV/EvaluateCNV $PREFIX/bin
