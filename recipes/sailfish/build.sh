#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir
ln -s $outdir/bin/sailfish $PREFIX/bin
