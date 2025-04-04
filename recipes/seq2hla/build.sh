#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
chmod a+x seq2HLA.py
cp -r * $outdir
ln -s $outdir/seq2HLA.py $PREFIX/bin/seq2HLA
