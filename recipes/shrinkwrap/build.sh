#!/bin/bash

set -e
set -x

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_INCLUDEDIR=include \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  ${SRC_DIR}

make -j${CPU_COUNT}
make install
make test

