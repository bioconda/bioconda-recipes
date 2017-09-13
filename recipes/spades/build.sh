#!/bin/bash

set -e -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

pushd .
PREFIX=$outdir ./spades_compile.sh
popd
ln -s $outdir/bin/* $PREFIX/bin
