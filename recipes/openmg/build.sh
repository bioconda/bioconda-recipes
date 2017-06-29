#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp OMG.jar $outdir/openmg.jar
cp $RECIPE_DIR/openmg.sh $outdir/openmg
ls -l $outdir
ln -s $outdir/openmg $PREFIX/bin
chmod 0755 "${PREFIX}/bin/openmg"

