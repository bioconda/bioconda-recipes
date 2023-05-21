#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/vcf2genome.py $outdir/vcf2genome 
ls -l $outdir
ln -s $outdir/vcf2genome $PREFIX/bin
chmod 0755 ${PREFIX}/bin/vcf2genome
