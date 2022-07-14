#!/bin/bash
set -eux -o pipefail

compgen -c # will list all the commands you could run.
compgen -c | grep gcc # will list all the commands you could run.
exit 1

# make compilation not be dependent on locale settings
export LC_ALL=C

# build cobs
mkdir -p build
cd build
cmake -DCMAKE_C_COMPILER=x86_64-conda-linux-gnu-gcc -DCMAKE_CXX_COMPILER=x86_64-conda-linux-gnu-g++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make -j1

# test
make test

# install
make install
