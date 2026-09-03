#!/bin/bash

cd FM/
make CC="$CC" CXX="$CXX"
cd ../semiWFA/
make CC="$CC" CXX="$CXX"
cd ../
make CC="$CC" CXX="$CXX"
mkdir -p $PREFIX/bin
cp panaln $PREFIX/bin
