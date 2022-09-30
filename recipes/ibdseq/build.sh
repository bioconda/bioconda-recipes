#!/bin/bash

echo $PREFIX
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp  ibdseq.r1206.jar $outdir/ibdseq.jar
cp $RECIPE_DIR/ibdseq $outdir/
chmod +x $outdir/ibdseq
ln -s $outdir/ibdseq $PREFIX/bin

