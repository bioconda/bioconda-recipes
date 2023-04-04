#!/bin/bash

mkdir build
cd build
cmake
make
make test
make install
