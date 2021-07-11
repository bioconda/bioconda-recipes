#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
ls
cp *BRBseqTools.*.jar $outdir/BRBseqTools.jar
cp $RECIPE_DIR/BRBseqTools.py $outdir/BRBseqTools
ls -l $outdir
ln -s $outdir/BRBseqTools $PREFIX/bin/BRBseqTools
chmod 0755 "${PREFIX}/bin/BRBseqTools"

