#!/bin/sh

mkdir build
cd build

cmake ..
make -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install bin/Bloocoo "${PREFIX}/bin/"
