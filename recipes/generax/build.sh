#!/bin/bash

# pthreads
mkdir build
pushd build
  cmake ..
  make
  install -d ${PREFIX}/bin
  install ../build/bin/generax ${PREFIX}/bin
  install ../build/bin/JointSearch ${PREFIX}/bin
popd

