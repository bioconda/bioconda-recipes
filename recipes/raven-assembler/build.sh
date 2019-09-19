#!/bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make



cp ./bin/raven $PREFIX/bin/raven
