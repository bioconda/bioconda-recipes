#!/bin/bash

mkdir build
cd build

cmake ..
make -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install bin/TakeABreak "${PREFIX}/bin/"
