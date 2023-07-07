#!/usr/bin/env bash

KMER_SIZE_LIST="32 64 96 128 160 192 224 256"

if [[ $OSTYPE == darwin* ]]; then
  PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15"
else
  PLATFORM_FLAGS=""
fi

mkdir -p $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DNATIVE=OFF \
                    -DCONDA_BUILD=ON \
                    -DWITH_MODULES=ON \
                    -DWITH_HOWDE=ON \
                    -DKMER_LIST="${KMER_SIZE_LIST}" \
                    -DWITH_SOCKS=ON \
                    ${PLATFORM_FLAGS}

cmake --build ./build

# Copy kmtricks binaries
cp ./bin/kmtricks $PREFIX/bin
cp ./bin/kmtricks-socks $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DNATIVE=OFF \
                    -DWITH_PLUGIN=ON \
                    -DCONDA_BUILD=ON \
                    -DWITH_MODULES=ON \
                    -DKMER_LIST="${KMER_SIZE_LIST}" \
                    ${PLATFORM_FLAGS}

cmake --build ./build

cp ./bin/kmtricks $PREFIX/bin/kmtricksp
