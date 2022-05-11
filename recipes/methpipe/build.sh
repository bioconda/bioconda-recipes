#!/bin/bash

mkdir -p ${PREFIX}

mkdir build && cd build
../configure --prefix ${PREFIX}
make
make install

