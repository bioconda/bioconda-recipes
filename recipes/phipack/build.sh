#!/bin/sh

cd PhiPack/src/
mkdir -p $PREFIX/bin

make CXX=$CC CXXFLAGS="$CFLAGS"
ls -l
cp ../Phi $PREFIX/bin
cp ../ppma_2_bmp $PREFIX/bin
cp ../Profile $PREFIX/bin

chmod +x $PREFIX/bin/*
