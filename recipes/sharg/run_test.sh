#!/bin/bash
set -exuo pipefail

cmake -S test \
      -B build

make -C build -j "${CPU_COUNT}"

./build/sharg_package_test --help
