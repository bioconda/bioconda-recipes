#!/bin/bash

set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp *.R $outdir
cp README.md $outdir
cp pileupParser $outdir
cp uniqueSNPmultithreading $outdir
cp smeg $outdir
chmod +x $outdir/smeg

ln -s $outdir/smeg $PREFIX/bin/smeg
cp $outdir/smeg $PREFIX/bin/.
