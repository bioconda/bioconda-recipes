#!/bin/bash
set -eu

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin

rm -f Canvas
cp $RECIPE_DIR/Canvas.sh Canvas
chmod +x Canvas
rm -f Tools/EvaluateCNV/EvaluateCNV
cp $RECIPE_DIR/EvaluateCNV.sh Tools/EvaluateCNV/EvaluateCNV
chmod +x Tools/EvaluateCNV/EvaluateCNV

cp -r * $OUTDIR
ln -s $OUTDIR/Canvas $PREFIX/bin
ln -s $OUTDIR/Tools/EvaluateCNV/EvaluateCNV $PREFIX/bin
