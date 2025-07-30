#!/bin/bash

set -xe

# pthreads
mkdir build
pushd build
  cmake ..
  make -j ${CPU_COUNT}
  install -d ${PREFIX}/bin
  install ../build/bin/generax ${PREFIX}/bin
popd

