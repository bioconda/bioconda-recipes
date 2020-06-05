#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME

cp ./fasta-splitter.pl $outdir/
chmod +x $outdir/fasta-splitter.pl

mkdir -p $PREFIX/bin
ln -s $outdir/fasta-splitter.pl $PREFIX/bin/fasta-splitter
