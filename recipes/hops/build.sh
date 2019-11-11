#!/bin/bash
set -eu -o pipefail

outdir=${PREFIX}/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo $outdir
mkdir -p $outdir
mkdir -p ${PREFIX}/bin
cp -R * $outdir/
cp $RECIPE_DIR/hops.py $outdir/hops
cp $RECIPE_DIR/MaltExtract.py $outdir/MaltExtract
ls -l $RECIPE_DIR
ls -l $outdir
ln -s $outdir/hops ${PREFIX}/bin
ln -s $outdir/MaltExtract ${PREFIX}/bin
mv $outdir/postprocessing.AMPS.r ${PREFIX}/bin/postprocessing.AMPS.r
chmod 0755 ${PREFIX}/bin/hops
chmod 0755 ${PREFIX}/bin/MaltExtract
chmod 0755 ${PREFIX}/bin/postprocessing.AMPS.r

