#!/bin/bash
sed -i.bak 's/Boost_USE_STATIC_LIBS OFF/Boost_USE_STATIC_LIBS ON/' CMakeLists.txt
git submodule update --init --recursive
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make 
popd
mkdir -p $PREFIX/bin
cp ./bin/artic-tools ${PREFIX}/bin/
