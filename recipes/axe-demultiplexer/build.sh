#!/bin/bash

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} -DNO_OPENMP=yes
if [ "$(uname)" == "Linux" ]
then
    make all test install
else
    # The python-based integration test expects linux so fails on OSX
    make all install
fi
