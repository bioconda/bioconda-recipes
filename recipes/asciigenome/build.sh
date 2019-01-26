#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# To be removed after shebang is fixed is ASCIIGenome repository
sed 's|#!/bin/sh|#!/bin/bash|' ASCIIGenome > $outdir/ASCIIGenome

cp ASCIIGenome.jar $outdir
chmod a+x $outdir/ASCIIGenome
ln -s $outdir/ASCIIGenome $PREFIX/bin
