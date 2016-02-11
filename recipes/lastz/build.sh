#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

make 

chmod +x  src/lastz
chmod +x  src/lastz

mv src/lastz $PREFIX/bin
mv src/lastz_D $PREFIX/bin

