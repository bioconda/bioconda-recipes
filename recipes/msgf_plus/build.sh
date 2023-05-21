#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/msgf_plus.py $outdir/msgf_plus
ls -l $outdir
ln -s $outdir/msgf_plus $PREFIX/bin
chmod 0755 "${PREFIX}/bin/msgf_plus"
