#!/bin/bash

set -exo pipefail

sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' CMakeLists.txt

mkdir -p build
cd build
cmake "${SRC_DIR}" "${CMAKE_ARGS}"
make
make install
