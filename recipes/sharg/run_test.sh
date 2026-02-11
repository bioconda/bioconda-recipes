#!/bin/bash
set -exuo pipefail

cmake -S test \
      -B build

make -C build -j "${CPU_COUNT}"

./build/sharg_test_package --help
