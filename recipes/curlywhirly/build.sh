#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
chmod +x $outdir/curlywhirly
ln -s $outdir/curlywhirly $PREFIX/bin