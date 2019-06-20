#!/bin/bash

#export CPPFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
#export CPATH=${PREFIX}/include

mkdir -p "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM" "$PREFIX/bin"
export CXXFLAGS="-std=c++0x -Wall -fopenmp  -DGZSTREAM_NAMESPACE=gz -g -I."
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -L. -lkraken -lz"
export CPATH="${PREFIX}/include"

chmod u+x install_kraken_conda.sh
./install_kraken_conda.sh "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
for bin in kraken kraken-build kraken-filter kraken-mpa-report kraken-report kraken-translate; do
    sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin
    rm -f $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin.bak
    chmod +x "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin"
    ln -s "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin" "$PREFIX/bin/$bin"
done

