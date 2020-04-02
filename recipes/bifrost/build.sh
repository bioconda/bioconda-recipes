#!/bin/bash

mkdir build
pushd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
popd
