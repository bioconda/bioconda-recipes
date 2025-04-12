#!/bin/bash

cd FM/
make
cd ../semiWFA/
make
cd ../
make
mkdir -p $PREFIX/bin
cp panaln $PREFIX/bin

