#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r bin $outdir
cp -r share $outdir
ln -s $outdir/bin/* $PREFIX/bin
