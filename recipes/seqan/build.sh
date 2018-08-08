#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake .. -DSEQAN_BUILD_SYSTEM=SEQAN_RELEASE_LIBRARY

make
