#!/bin/sh

mkdir -p $PREFIX/bin/

# To run boost linking $CC and $CXX to gcc and g++
ln -s $CC $PREFIX/bin/gcc
ln -s $CXX $PREFIX/bin/g++

make

cp build/bin/gfastats $PREFIX/bin/
chmod +x $PREFIX/bin/gfastats

# Remove the fake links
unlink $PREFIX/bin/gcc
unlink $PREFIX/bin/g++
