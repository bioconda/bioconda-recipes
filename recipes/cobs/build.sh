#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# build cobs
mkdir -p build
cd build
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      cmake -DCMAKE_C_COMPILER=x86_64-conda-linux-gnu-gcc -DCMAKE_CXX_COMPILER=x86_64-conda-linux-gnu-g++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
elif [[ "$OSTYPE" == "darwin"* ]]; then
      cmake -DCMAKE_C_COMPILER=x86_64-apple-darwin20-gcc-10 -DCMAKE_CXX_COMPILER=x86_64-apple-darwin20-g++-10 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
else
      echo "Unsupported OS"
      exit 1
fi
make -j1

# test
make test

# install
make install
