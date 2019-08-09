#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME

files="config.txt COPYING.txt pal_finder_v${PKG_VERSION}.pl README.txt simple.ref"
for f in $files ; do
    cp ./$f $outdir/
done
sed -i.bak -e 's,^#!/usr/bin/perl,#!/usr/bin/env perl,g' $outdir/pal_finder_v${PKG_VERSION}.pl
chmod +x $outdir/pal_finder_v${PKG_VERSION}.pl

mkdir -p $PREFIX/bin
ln -s $outdir/pal_finder_v${PKG_VERSION}.pl $PREFIX/bin/pal_finder
