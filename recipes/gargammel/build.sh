#!/bin/bash

## Following https://bioconda.github.io/contributor/troubleshooting.html#g-or-gcc-not-found
make CC=$CC

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

ln -s $outdir/gargammel.pl $PREFIX/bin/gargammel


