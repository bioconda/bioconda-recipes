#!/usr/bin/env bash

KMER_SIZE_LIST="32 64 96 128 160 192 224 256"

mkdir -p $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DNATIVE=OFF \
                    -DCONDA_BUILD=ON \
                    -DWITH_MODULES=ON \
                    -DKMER_LIST="${KMER_SIZE_LIST}"

cmake --build ./build -j 8

cp ./bin/kmtricks $PREFIX/bin

