#!/bin/bash

sed \
    -e 's/CPROGNAME\.cpp/corrprofile.cpp/g' \
    -e 's/CPROGNAME/dnp-corrprofile/g' \
    CMakeLists.template > CMakeLists.txt

mkdir -p  build
cd build

# Require 10.12 SDK for SeqAN's use of std::shared_timed_mutex
export MACOSX_DEPLOYMENT_TARGET=10.12
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=14 \
    ..
make
install -d "${PREFIX}/bin"
install dnp-corrprofile "${PREFIX}/bin/"
