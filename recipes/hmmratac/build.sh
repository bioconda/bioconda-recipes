#!/bin/bash
outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $outdir
mkdir -p ${PREFIX}/bin
mv HMMRATAC_V${PKG_VERSION}_exe.jar $outdir/HMMRATAC.jar
cp $RECIPE_DIR/HMMRATAC $outdir/
ln -s $outdir/HMMRATAC $PREFIX/bin/
chmod 0755 "${PREFIX}/bin/HMMRATAC"
