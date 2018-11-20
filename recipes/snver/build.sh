#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/SNVerIndividual.py $outdir/SNVerIndividual.py
cp $RECIPE_DIR/SNVerPool.py $outdir/SNVerPool.py
ln -s $outdir/SNVerIndividual.py $PREFIX/bin/SNVerIndividual
ln -s $outdir/SNVerPool.py $PREFIX/bin/SNVerPool
chmod 0755 "${PREFIX}/bin/SNVerIndividual"
chmod 0755 "${PREFIX}/bin/SNVerPool"
