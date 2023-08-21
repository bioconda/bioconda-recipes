#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir
rm -rf $outdir/share/demo
sed -i.bak 's/__file__/os.path.realpath(__file__)/' $outdir/bin/configManta.py
ln -s $outdir/bin/configManta.py $PREFIX/bin
ln -s $outdir/libexec/convertInversion.py $PREFIX/bin
ln -s $outdir/libexec/denovo_scoring.py $PREFIX/bin
