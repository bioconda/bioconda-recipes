#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r ICEfamily_refer $outdir/ICEfamily_refer
cp -r data $outdir/data
cp -r scripts $outdir/scripts
cp ICEfinder_modified4_yxl.pl $outdir/ICEfinder_modified4_yxl.pl
cp ICEcream.sh $outdir/ICEcream.sh

chmod 0755 $outdir/ICEfamily_refer/familytools/plotting_script.py
chmod 0755 $outdir/ICEcream.sh

ln -s $outdir/ICEfamily_refer/familytools/plotting_script.py $PREFIX/bin
ln -s $outdir/ICEcream.sh $PREFIX/bin
