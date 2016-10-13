#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/spectra-cluster-cli.py $outdir/spectra-cluster-cli
ls -l $outdir
ln -s $outdir/spectra-cluster-cli $PREFIX/bin
chmod 0755 "${PREFIX}/bin/spectra-cluster-cli"
