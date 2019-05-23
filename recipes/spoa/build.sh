#!/bin/bash
set -eoux pipefail

pushd vendor
wget https://github.com/rvaser/bioparser/archive/1.2.1.tar.gz
tar xf barparser-1.2.1.tar.gz
mv barparser-1.2.1 bioparser
popd

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
