#!/bin/sh

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake ..
make -j8

cp KmerInShort $PREFIX/bin
