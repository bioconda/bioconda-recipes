#!/usr/bin/env bash

mkdir build
cd build
cmake ../src
make
cp omniclip ${PREFIX}/bin
