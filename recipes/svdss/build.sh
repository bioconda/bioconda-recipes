#!/bin/bash

git clone https://github.com/jeffdaily/parasail.git
cd parasail
git checkout v2.5
mkdir build
cd build
cmake ..
make
cmake --install . --prefix ${PREFIX} 
cd ../..

git clone https://github.com/maxbachmann/rapidfuzz-cpp.git
cd rapidfuzz-cpp
git checkout d1e8237
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
cd ../..

git clone https://github.com/yangao07/abPOA.git
cd abPOA
git checkout 42a09de
cd ..

git clone https://github.com/5cript/interval-tree.git

git clone https://github.com/lh3/ropebwt2.git

make

mkdir -p ${PREFIX}/bin
cp SVDSS ${PREFIX}/bin
