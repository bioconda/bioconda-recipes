#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cd Natural_Product_Likeness_calculator_2.1/
cp NP-Likeness-2.1.jar $outdir/
cp $RECIPE_DIR/np-likeness.py $outdir/np-likeness
ls -l $outdir
ln -s $outdir/np-likeness $PREFIX/bin
chmod 0755 "${PREFIX}/bin/np-likeness"
