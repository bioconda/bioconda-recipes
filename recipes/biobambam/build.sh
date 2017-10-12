#!/bin/bash
set -eu

cd *-release-*/x86_64-etch-linux-gnu
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -r bin $outdir
cp -r etc $outdir
cp -r lib $outdir
cp -r share $outdir
ln -s $outdir/bin/bam* $PREFIX/bin
