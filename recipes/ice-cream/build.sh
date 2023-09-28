#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir
cp ICEfamily_refer/familytools/plotting_script.py $outdir/plotting_script.py

chmod 0755 $outdir/plotting_script.py
chmod 0755 $outdir/ICEcream.sh

ln -s $outdir/plotting_script.py $PREFIX/bin
ln -s $outdir/ICEcream.sh "$PREFIX/bin
