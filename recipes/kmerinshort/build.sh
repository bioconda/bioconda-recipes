#!/bin/sh


mkdir  build;
cd build;
cmake ..
make -j8

cp KmerInShort $PREFIX




