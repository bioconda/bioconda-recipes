#!/bin/bash

mkdir -p $PREFIX/bin

export HDF5_INCLUDE=$PREFIX/include
export HDF5_LIB=$PREFIX/lib

./configure.py CXXFLAGS=-O3 --shared --sub --no-pbbam
make configure-submodule
make build-submodule
make

cp blasr $PREFIX/bin
cp utils/loadPulses $PREFIX/bin
cp utils/pls2fasta $PREFIX/bin
cp utils/samtoh5 $PREFIX/bin
cp utils/samtom4 $PREFIX/bin
cp utils/samFilter $PREFIX/bin
cp utils/sawriter $PREFIX/bin
cp utils/sdpMatcher  $PREFIX/bin
