#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -D ENABLE_CONAN=OFF \
      -D ENABLE_PERF_TESTING=OFF \
      -D ENABLE_PYTHON=OFF \
      ..
make -j
make install
