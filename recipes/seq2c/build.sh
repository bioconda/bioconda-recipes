#!/bin/bash

target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# fix references to handle symlinks
sed -i.bak 's/FindBin::Bin/FindBin::RealBin/' cov2lr.pl
sed -i.bak 's/FindBin::Bin/FindBin::RealBin/' lr2gene.pl

cp -r * $target
ln -s $target/seq2cov.pl $PREFIX/bin
ln -s $target/cov2lr.pl $PREFIX/bin
ln -s $target/lr2gene.pl $PREFIX/bin
