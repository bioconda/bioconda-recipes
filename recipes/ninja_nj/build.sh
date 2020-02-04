#!/bin/sh
set -x -e

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX=$CXX
cp Ninja ${PREFIX}/bin
