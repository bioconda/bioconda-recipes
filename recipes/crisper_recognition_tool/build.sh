#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp CRT1.2-CLI.jar $outdir/
cp $RECIPE_DIR/crt.py $outdir/crt
ls -l $outdir
ln -s $outdir/crt $PREFIX/bin
chmod 0755 "${PREFIX}/bin/crt"
