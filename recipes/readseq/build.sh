#!/bin/bash

set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -R * $outdir/
cp $RECIPE_DIR/${PKG_NAME} $outdir

ls -l $outdir
ln -s $outdir/${PKG_NAME} $PREFIX/bin

chmod +x $PREFIX/bin/${PKG_NAME}




