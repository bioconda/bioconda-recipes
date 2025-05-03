#!/bin/bash

cd KMC
make
cd ..
cd build
cmake .. -DMAX_KMER_LENGTH=64 -DCMAKE_BUILD_TYPE=Release
make
