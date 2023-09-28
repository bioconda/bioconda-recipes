#!/bin/bash

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DORFANAGE_BUILD_LIBBIGWIG=OFF
make
make install
