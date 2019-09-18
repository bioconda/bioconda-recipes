#!/bin/sh

cd PhiPack/src/
mkdir -p $PREFIX/bin

make CXX=$CC CXXFLAGS="$CFLAGS"
cp Phi $PREFIX/bin
cp -r ppma_2_bmp $PREFIX/bin
cp Profile $PREFIX/bin

chmod -R +x $PREFIX/bin/*
