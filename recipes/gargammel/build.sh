#!/bin/bash

sed -i  's/make -C libgab/make -C libgab CC=$(CC)/' Makefile

make CC=$CXX

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

ln -s $outdir/gargammel.pl $PREFIX/bin/gargammel


