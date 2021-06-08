#!/bin/bash

mkdir build && cd build
cmake ..
make

mkdir -p ${PREFIX}/bin

cp ../bin/bayesTyper ${PREFIX}/bin
cp ../bin/bayesTyperTools ${PREFIX}/bin
