#!/bin/bash

mkdir -p ${PREFIX}/bin
cmake -S . -B build
cmake --build build
cp build/mupbwt ${PREFIX}/bin

