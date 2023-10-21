#!/bin/bash

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} -DNO_OPENMP=yes
make all test install
