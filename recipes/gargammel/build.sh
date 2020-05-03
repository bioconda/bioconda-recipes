#!/bin/bash

sed -i.bak  's/make -C libgab/make -C libgab CXX=$(CC)/' Makefile

## Following https://bioconda.github.io/contributor/troubleshooting.html#g-or-gcc-not-found
make CC=$CXX

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

ln -s $outdir/gargammel.pl $PREFIX/bin/gargammel
