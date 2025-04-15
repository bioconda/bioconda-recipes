#!/bin/bash

export CC=$(which gcc)
export CXX=$(which g++)
cd FM/
make
cd ../semiWFA/
make
cd ../
make
mkdir -p $PREFIX/bin
cp panaln $PREFIX/bin

