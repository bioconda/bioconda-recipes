#!/bin/bash
set -eoux pipefail

mkdir build
pushd build
cmake -DCMAKE_BUILD_TYPE=Release -Dspoa_build_executable=ON ..
make

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
mv ../include/spoa ${PREFIX}/include/
mv lib/libspoa.a ${PREFIX}/lib/
mv bin/spoa ${PREFIX}/bin/
