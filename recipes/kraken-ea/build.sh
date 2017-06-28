#!/bin/bash

#export CPPFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
#export CPATH=${PREFIX}/include

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"
export CXXFLAGS="-std=c++0x -Wall -fopenmp  -DGZSTREAM_NAMESPACE=gz -g -I."
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -L. -lkraken -lz"
export CPATH="${PREFIX}/include"

chmod u+x install_kraken_conda.sh
./install_kraken_conda.sh "$PREFIX/libexec"
for bin in kraken kraken-build kraken-filter kraken-mpa-report kraken-report kraken-translate; do
    sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' $PREFIX/libexec/$bin
    rm -f $PREFIX/libexec/$bin.bak
    chmod +x "$PREFIX/libexec/$bin"
    ln -s "$PREFIX/libexec/$bin" "$PREFIX/bin/$bin"
done

