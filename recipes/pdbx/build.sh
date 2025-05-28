#!/bin/bash

set -exo pipefail

mkdir -p build
cd build
cmake "${SRC_DIR}" "${CMAKE_ARGS}"
make
make install
