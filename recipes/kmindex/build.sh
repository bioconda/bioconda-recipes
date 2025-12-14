#!/usr/bin/env bash

if [[ "${OS}" == "Darwin" ]]; then
    SERVER_FLAG="-DWITH_SERVER=OFF"
else
    SERVER_FLAG="-DWITH_SERVER=ON"
fi

mkdir -p $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DFMT_HEADER_ONLY=ON \
                    -DSPDLOG_HEADER_ONLY=ON \
                    -DPORTABLE_BUILD=ON \
                    $SERVER_FLAG

cmake --build ./build -j 8

cp ./build/app/kmindex/kmindex $PREFIX/bin

if [[ "${OS}" == "Linux" ]]; then
    cp ./build/app/kmindex/kmindex-server $PREFIX/bin
fi
