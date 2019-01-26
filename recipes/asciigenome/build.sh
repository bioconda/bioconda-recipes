#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# To be removed after shebang is fixed is ASCIIGenome repository
mv ASCIIGenome ASCIIGenome.tmp
sed 's|#!/bin/sh|#!/bin/bash|' ASCIIGenome.tmp > ASCIIGenome
rm ASCIIGenome.tmp

cp ASCIIGenome.jar $outdir
cp ASCIIGenome $outdir
chmod a+x $outdir/ASCIIGenome
ln -s $outdir/ASCIIGenome $PREFIX/bin
