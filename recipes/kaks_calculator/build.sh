#!/bin/sh

mkdir -p $PREFIX/bin

make CC="${CXX}" CFLAGS="${CXXFLAGS}"
chmod +x src/KaKs_Calculator

mv src/KaKs_Calculator $PREFIX/bin
