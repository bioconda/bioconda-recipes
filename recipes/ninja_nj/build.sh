#!/bin/sh
set -x -e

export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX=$CXX
cp Ninja ${PREFIX}/bin
