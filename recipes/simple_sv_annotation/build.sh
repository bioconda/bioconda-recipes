#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp simple_sv_annotation.py $outdir
cp *.txt $outdir
chmod a+x $outdir/simple_sv_annotation.py
ln -s $outdir/simple_sv_annotation.py $PREFIX/bin
