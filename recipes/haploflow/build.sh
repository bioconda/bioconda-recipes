#!/bin/bash

mkdir -p build
cd build
cmake ..
make

cp haploflow $PREFIX/bin/