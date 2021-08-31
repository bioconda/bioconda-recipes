#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp -R dnaA_database $outdir
cp *.R $outdir/
cp smeg growth_est_denovo growth_est_ref build_sp pileupParser uniqueSNPmultithreading uniqueClusterSNP $outdir
chmod +x $outdir/smeg
chmod +x $outdir/uniqueSNPmultithreading
chmod +x $outdir/pileupParser
chmod +x $outdir/growth_est_denovo
chmod +x $outdir/growth_est_ref
chmod +x $outdir/build_sp
chmod +x $outdir/uniqueClusterSNP

ln -s $outdir/smeg $PREFIX/bin/smeg
