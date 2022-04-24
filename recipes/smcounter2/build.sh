#!/bin/bash
set -eu
# Only installs the parts for running THetA not pre-prearation
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp *.py *.R $outdir

# data requirements
mkdir -p $outdir/data/annotation
mkdir -p $outdir/data/annotation/hg19
wget https://storage.googleapis.com/qiaseq-dna/data/annotation/bkg.error.v2.RData \
     -P $outdir/data/annotation/
mkdir -p $outdir/data/annotation/hg19
wget https://storage.googleapis.com/qiaseq-dna/data/annotation/SR_LC_SL.full.bed \
     https://storage.googleapis.com/qiaseq-dna/data/annotation/simpleRepeat.full.bed \
     -P $outdir/data/annotation/hg19

chmod a+x $outdir/run.py
chmod a+x $outdir/*.R
ln -s $outdir/run.py $PREFIX/bin/smCounter2
