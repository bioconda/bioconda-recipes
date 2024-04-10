#!/bin/bash
export CPLUS_INCLUDE_PATH=${PREFIX}/include
mkdir build && cd build
cmake ..
make

mkdir -p ${PREFIX}/bin

cp ../bin/bayesTyper ${PREFIX}/bin
cp ../bin/bayesTyperTools ${PREFIX}/bin
