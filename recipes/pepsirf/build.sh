#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make pepsirf

mkdir -p "${PREFIX}/bin/"
cp pepsirf "${PREFIX}/bin/"
