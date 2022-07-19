#!/bin/bash

# pthreads
mkdir build
pushd build
  cmake ..
  make
  install -d ${PREFIX}/bin
  install ../build/bin/generax ${PREFIX}/bin
popd

