#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# build cobs
echo "cobs/util/fs.hpp!"
cat cobs/util/fs.hpp
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make -j1

# test
make test

# install
make install
