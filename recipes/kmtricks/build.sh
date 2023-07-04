#!/usr/bin/env bash

if [[ $OSTYPE == linux* ]]; then
    PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} -DCAMKE_OSX_DEPLOYMENT_TARGET=10.15"
else
    PLATFORM_FLAGS=""
fi

KMER_SIZE_LIST="32 64 96 128 160 192 224 256"

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

cp -r ./bin/kmtricks $PREFIX/bin
cp -r ./bin/kmtricks-socks $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DNATIVE=OFF \
                    -DWITH_PLUGIN=ON \
                    -DCONDA_BUILD=ON \
                    -DWITH_MODULES=ON \
                    -DKMER_LIST="${KMER_SIZE_LIST}" \
                    ${PLATFORM_FLAGS}

cmake --build ./build

cp -r ./bin/kmtricks $PREFIX/bin/kmtricksp
