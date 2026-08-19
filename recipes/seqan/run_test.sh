#!/bin/bash
set -xe

mkdir -p build
cmake -S test -B build
cmake --build build
./build/seqan_package_test
