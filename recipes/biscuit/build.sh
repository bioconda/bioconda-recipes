#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ..
sed -i "s/= gcc/?= gcc/g" ../lib/sgsl/Makefile
sed -i "s/= gcc/?= gcc/g" ../lib/utils/Makefile
make
make install
