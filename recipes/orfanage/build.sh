#!/bin/bash

set -xe

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DORFANAGE_BUILD_LIBBIGWIG=OFF
make -j ${CPU_COUNT}
make install
