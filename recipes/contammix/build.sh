#!/bin/bash
set -eu -o pipefail

$R CMD INSTALL --build .
bash ./configure

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/ 
ls -l $outdir
ln -s $outdir/exec/estimate.R $PREFIX/bin/contammix
chmod 0755 ${PREFIX}/bin/contammix
