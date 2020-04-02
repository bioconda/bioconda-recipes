#!/bin/bash

mkdir build
pushd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make VERBOSE=1
make install
popd
