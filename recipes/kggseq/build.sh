#!/bin/bash

set -x -e

export LD_LIBRARY_PATH="${PREFIX}/lib"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp kggseq.jar $outdir/kggseq.jar
cp $RECIPE_DIR/kggseq $outdir/

chmod +x $outdir/kggseq
ln -s $outdir/kggseq $PREFIX/bin

kggseq