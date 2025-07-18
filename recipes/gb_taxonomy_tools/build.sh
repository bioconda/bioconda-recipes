#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
sed -i '1i #include <string.h>' src/taxonomy2tree.c
sed -i '1s/2.8/3.10/' CMakeLists.txt
sed -i '10c\add_definitions(-D_GNU_SOURCE)' CMakeLists.txt
cd build
cmake -DINSTALL_PREFIX:PATH=$PREFIX  .. 
make install
cp $PREFIX/bin/taxonomy-reader $PREFIX/bin/taxonomyReader
chmod 755 $PREFIX/bin/taxonomyReader
