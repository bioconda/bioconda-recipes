#!/bin/bash
export CC=$CC
export CXX=$CXX
make
mkdir -p $PREFIX/bin
cp spectral_hk $PREFIX/bin/
