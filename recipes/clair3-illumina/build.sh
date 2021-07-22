#!/bin/bash

mkdir -pv $PREFIX/bin
cp -rv preprocess $PREFIX/bin
cd $PREFIX/bin/preprocess/realign
g++ -std=c++14 -O1 -shared -fPIC -o realigner ssw_cpp.cpp ssw.c realigner.cpp
#g++ -std=c++11 -shared -fPIC -o debruijn_graph -O3 debruijn_graph.cpp -I $PREFIX/include -L $PREFIX/lib




