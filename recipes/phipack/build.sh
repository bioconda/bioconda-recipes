#!/bin/sh

# There's a . directory that's ignored on OSX but not Linux
if [[ $(uname -s) == "Darwin" ]]; then
cd src
else
cd PhiPack/src/
fi
mkdir -p $PREFIX/bin

make CXX=$CC CXXFLAGS="$CFLAGS"
cp Phi $PREFIX/bin
cp -r ppma_2_bmp $PREFIX/bin
cp Profile $PREFIX/bin

chmod -R +x $PREFIX/bin/*
