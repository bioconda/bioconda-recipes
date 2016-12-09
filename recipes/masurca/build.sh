#!/bin/bash

echo `pwd`
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cd $SRC_DIR
echo $SRC_DIR
export DEST=$PREFIX
./install.sh
