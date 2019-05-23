#!/bin/bash
set -eoux pipefail

mkdir build
pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
mv ../include/spoa ${PREFIX}/include/
mv lib/libspoa.a ${PREFIX}/lib/
find . -name spoa -print
mv spoa ${PREFIX}/bin/
