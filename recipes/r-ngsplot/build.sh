#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R {bin,database,example,galaxy,lib,webings,LICENSE} ${outdir}/
#Set up links for 
for f in ${outdir}/bin/*; do
    ln -s ${f} ${PREFIX}/bin
    fbname=$(basename "$f")
done
