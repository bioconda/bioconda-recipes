#!/bin/bash
set -eu

cd x86_64-linux-gnu/$PKG_VERSION

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -r bin $outdir
cp -r lib $outdir
cp -r share $outdir
ln -s $outdir/bin/bam* $PREFIX/bin
