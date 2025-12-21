#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak '1i #include <string.h>' src/taxonomy2tree.c
sed -i.bak '1s/2.8/3.10/' CMakeLists.txt
sed -i.bak '10c\add_definitions(-D_GNU_SOURCE)' CMakeLists.txt

cmake -S . -B build -DINSTALL_PREFIX:PATH="${PREFIX}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"
cp -f $PREFIX/bin/taxonomy-reader $PREFIX/bin/taxonomyReader
chmod 755 $PREFIX/bin/taxonomyReader
