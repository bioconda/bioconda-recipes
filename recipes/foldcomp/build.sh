#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..
make -j${CPU_COUNT} ${VERBOSE_CM}
install src/foldcomp "${PREFIX}/bin/"
