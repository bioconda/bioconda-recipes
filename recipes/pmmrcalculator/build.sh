#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/ 
ls -l $outdir
ln -s $outdir/pMMRCalculator.py $PREFIX/bin/pmmrcalculator
chmod 0755 ${PREFIX}/bin/pmmrcalculator
