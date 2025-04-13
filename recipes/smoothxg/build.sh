#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak -e 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak -e 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak -e 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.16 FATAL_ERROR|VERSION 3.5|' CMakeLists.txt
rm -rf deps/spoa/*.bak
rm -rf deps/abPOA/*.bak
rm -rf *.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DEXTRA_FLAGS="-march=sandybridge -Ofast"
cmake --build build -j "${CPU_COUNT}"
install -v -m 0755 bin/* "${PREFIX}/bin"
