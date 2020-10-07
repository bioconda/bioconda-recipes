#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp *.py $outdir

chmod a+x $outdir/truvari.py
ln -s $outdir/truvari.py $PREFIX/bin/truvari
