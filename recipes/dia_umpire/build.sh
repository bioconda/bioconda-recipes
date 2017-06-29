#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R v${PKG_VERSION}/* $outdir/
cp $RECIPE_DIR/dia_umpire_se.py $outdir/dia_umpire_se
cp $RECIPE_DIR/dia_umpire_quant.py $outdir/dia_umpire_quant
ls -l $outdir
ln -s $outdir/dia_umpire_se $PREFIX/bin
ln -s $outdir/dia_umpire_quant $PREFIX/bin
chmod 0755 "${PREFIX}/bin/dia_umpire_se"
chmod 0755 "${PREFIX}/bin/dia_umpire_quant"
