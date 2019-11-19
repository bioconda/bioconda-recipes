#!/bin/bash

mkdir build && cd build
cmake ..
make

cp bin/bayesTyper ${PREFIX}/bin
cp bin/bayesTyperTools ${PREFIX}/bin
