#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp MetFrag2.4.2-CL.jar $outdir/metfrag.jar
cp $RECIPE_DIR/metfrag.sh $outdir/metfrag
ls -l $outdir
ln -s $outdir/metfrag $PREFIX/bin
chmod 0755 "${PREFIX}/bin/metfrag"

