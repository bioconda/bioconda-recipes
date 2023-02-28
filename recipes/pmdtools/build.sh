#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/ 
ls -l $outdir
ln -s $outdir/pmdtools.${PKG_VERSION}.py $PREFIX/bin/pmdtools
ln -s $outdir/plotPMD.v2.R $PREFIX/bin/plotPMD
chmod 0755 ${PREFIX}/bin/pmdtools
chmod 0755 ${PREFIX}/bin/plotPMD
