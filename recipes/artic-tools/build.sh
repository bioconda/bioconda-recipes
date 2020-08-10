#!/bin/bashi
git submodule update --init --recursive
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make 
popd
mkdir -p $PREFIX/bin
cp ./bin/artic-tools ${PREFIX}/bin/
