#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
ln -s $outdir/snpEff.jar $PREFIX/bin
ln -s $outdir/SnpSift.jar $PREFIX/bin