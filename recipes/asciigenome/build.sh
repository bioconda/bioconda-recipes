#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

sed -i '' 's|#!/bin/sh|#!/bin/bash|' ASCIIGenome

cp ASCIIGenome.jar $outdir
cp ASCIIGenome $outdir
chmod a+x $outdir/ASCIIGenome
ln -s $outdir/ASCIIGenome $PREFIX/bin
