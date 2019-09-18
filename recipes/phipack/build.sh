#!/bin/sh

cd PhiPack/src/

make CXX=$CC CXXFLAGS="$CFLAGS"
cp ../Phi $PREFIX/bin
cp ../ppma_2_bmp $PREFIX/bin
cp ../Profile $PREFIX/bin

chmod +x $PREFIX/bin/*
