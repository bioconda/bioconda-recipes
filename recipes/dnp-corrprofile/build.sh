#!/bin/bash

sed \
    -e 's/CPROGNAME\.cpp/corrprofile.cpp/g' \
    -e 's/CPROGNAME/dnp-corrprofile/g' \
    CMakeLists.template > CMakeLists.txt

mkdir -p  build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=14 \
    ..
make
install -d "${PREFIX}/bin"
install dnp-corrprofile "${PREFIX}/bin/"
