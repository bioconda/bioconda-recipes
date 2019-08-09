#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/clinod.py $outdir/clinod
ls -l $outdir
ln -s $outdir/clinod $PREFIX/bin
chmod 0755 "${PREFIX}/bin/clinod"

# clinod expects the batchman binary from SNNS in its folder,
# it should be installed here by the BioConda SNNS package:
ln -s $PREFIX/bin/batchman $outdir/batchman
