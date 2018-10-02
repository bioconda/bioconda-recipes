#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir

cp -r * $outdir
ln -s $outdir/moff_mbr.py  $PREFIX/bin/moff_mbr.py
ln -s $outdir/moff.py $PREFIX/bin/moff.py
ln -s $outdir/moff_all.py $PREFIX/bin/moff_all.py
