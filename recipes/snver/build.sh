#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/SNVerIndividual.py $outdir/SNVerIndividual.py
cp $RECIPE_DIR/SNVerPool.py $outdir/SNVerPool.py
ln -s $outdir/SNVerIndividual.py $PREFIX/bin/snver
ln -s $outdir/SNVerPool.py $PREFIX/bin/snver-pool
chmod 0755 "${PREFIX}/bin/snver"
chmod 0755 "${PREFIX}/bin/snver-pool"
