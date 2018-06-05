#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir 
#Set up links for 
for f in $outdir/*; do
    ln -s $outdir/* $PREFIX/bin
    fbname=$(basename "$f")
    chmod 0755 ${PREFIX}/bin/$fbname
done