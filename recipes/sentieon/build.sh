#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir

ln -s $outdir/bin/sentieon $PREFIX/bin/sentieon
ln -s $outdir/libexec/licsrvr $PREFIX/bin/sentieon-licsrvr
