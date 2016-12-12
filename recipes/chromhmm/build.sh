#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp ChromHMM.jar $outdir/
cp $RECIPE_DIR/ChromHMM.sh $outdir/
chmod +x $outdir/ChromHMM.sh
ln -s $outdir/ChromHMM.sh $PREFIX/bin

