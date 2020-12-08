#!/bin/bash

mkdir build
cd build
cmake --build . --target Balrog -- -j 3
make install