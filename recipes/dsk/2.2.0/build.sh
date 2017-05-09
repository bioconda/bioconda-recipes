#!/bin/bash
mkdir build
cd build
cmake ..
make -j $(nproc)
cp bin/* $PREFIX/bin
cp ext/gatb-core/bin/* $PREFIX/bin
