#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../mvicuna
make
make install
