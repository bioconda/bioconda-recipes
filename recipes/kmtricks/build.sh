#!/usr/bin/env bash

KMER_SIZE_LIST="32 64 96 128 160 192 224 256"

mkdir -p $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DNATIVE=OFF \
                    -DCONDA_BUILD=ON \
                    -DWITH_MODULES=ON \
                    -DWITH_HOWDE=ON \
                    -DKMER_LIST="${KMER_SIZE_LIST}" \
                    -DWITH_SOCKS=ON

cmake --build ./build

cp ./bin/kmtricks $PREFIX/bin
cp ./bin/kmtricks-socks $PREFIX/bin

# Compile kmtricks with plugin support
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DNATIVE=OFF \
                    -DWITH_PLUGIN=ON \
                    -DCONDA_BUILD=ON \
                    -DWITH_MODULES=ON \
                    -DKMER_LIST="${KMER_SIZE_LIST}"

cmake --build ./build

cp ./bin/kmtricks $PREFIX/bin/kmtricksp
