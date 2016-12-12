#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir
ln -s $outdir/run-bwamem $PREFIX/bin
