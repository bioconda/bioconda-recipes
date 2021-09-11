#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/MegaPath-Nano
cp -rv bin db_preparation docs Dockerfile README.md LICENSE $PREFIX/MegaPath-Nano
cp -s $PREFIX/MegaPath-Nano/bin/megapath_nano.py  $PREFIX/MegaPath-Nano/bin/megapath_nano_amr.py $PREFIX/MegaPath-Nano/bin/runMegaPath-Nano-Amplicon.sh $PREFIX/bin

cd $PREFIX/MegaPath-Nano/bin/realignment/realign/
$CXX -std=c++14 -O1 -shared -fPIC -o realigner ssw_cpp.cpp ssw.c realigner.cpp
$CXX -std=c++11 -shared -fPIC -o debruijn_graph -O3 debruijn_graph.cpp -I $PREFIX/include -L $PREFIX/lib
$CC -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c ssw.h
cd $PREFIX/MegaPath-Nano/bin/Clair-ensemble/Clair.beta.ensemble.cpu/clair/
$CXX ensemble.cpp -o ensemble
pip install biopython && pip install git+https://github.com/arpcard/rgi.git
