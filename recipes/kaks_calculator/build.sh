#!/bin/sh

mkdir -p $PREFIX/bin

pushd ./src
make CC="${CXX}" CFLAGS="${CXXFLAGS}"
popd
chmod +x src/KaKs_Calculator

mv src/KaKs_Calculator $PREFIX/bin
