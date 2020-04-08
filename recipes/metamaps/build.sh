#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./bootstrap.sh
./configure --with-boost=${PREFIX} --prefix=${PREFIX}
make metamaps

mkdir -p $PREFIX/bin
cp -f metamaps $PREFIX/bin/

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir $outdir
cp *pl $outdir
