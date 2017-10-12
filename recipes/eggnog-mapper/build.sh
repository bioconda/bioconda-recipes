#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir

cp -r * $outdir
ln -s $outdir/emapper.py $PREFIX/bin/emapper.py
ln -s $outdir/download_eggnog_data.py $PREFIX/bin/download_eggnog_data.py
