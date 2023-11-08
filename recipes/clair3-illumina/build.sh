#!/bin/bash

mkdir -pv $PREFIX/bin/preprocess
cp -rv preprocess/realign $PREFIX/bin/preprocess
cd $PREFIX/bin/preprocess/realign
$CXX -std=c++14 -O1 -shared -fPIC -o realigner ssw_cpp.cpp ssw.c realigner.cpp
$CXX -std=c++11 -shared -fPIC -o debruijn_graph -O3 debruijn_graph.cpp -I $PREFIX/include -L $PREFIX/lib




