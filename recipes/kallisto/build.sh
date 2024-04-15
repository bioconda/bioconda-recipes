#!/bin/bash

cd ext/htslib || exit 1
autoreconf --force --install --verbose
./configure
cd ../.. || exit 1
mkdir -p "${PREFIX}/bin"
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" .. -DUSE_HDF5=ON
make
make install
