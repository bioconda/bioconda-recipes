#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp cvbio.jar $outdir/cvbio.jar
cp $RECIPE_DIR/cvbio.py ${PREFIX}/bin/cvbio
chmod +x ${PREFIX}/bin/cvbio
