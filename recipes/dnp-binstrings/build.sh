#!/bin/bash

sed \
    -e 's/CPROGNAME\.cpp/binstrings.cpp/g' \
    -e 's/CPROGNAME/dnp-binstrings/g' \
    CMakeLists.template > CMakeLists.txt

mkdir -p  build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=14 \
    ..
make
install -d "${PREFIX}/bin"
install dnp-binstrings "${PREFIX}/bin/"
