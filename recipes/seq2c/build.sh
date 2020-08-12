#!/bin/bash

target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

cp -r * $target
ln -s $target/seq2cov.pl $PREFIX/bin
ln -s $target/cov2lr.pl $PREFIX/bin
ln -s $target/lr2gene.pl $PREFIX/bin
