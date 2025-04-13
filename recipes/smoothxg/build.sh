#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak -e 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak -e 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak -e 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.16 FATAL_ERROR|VERSION 3.5|' CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2 FATAL_ERROR|VERSION 3.5|' deps/WFA/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2|VERSION 3.5|' deps/abPOA/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6 FATAL_ERROR|VERSION 3.5|' deps/libbf/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.8.11|VERSION 3.5|' deps/sdsl-lite/CMakeLists.txt
rm -rf deps/spoa/*.bak
rm -rf deps/abPOA/*.bak
rm -rf deps/libbf/*.bak
rm -rf deps/sdsl-lite/*.bak
rm -rf *.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DEXTRA_FLAGS="-march=sandybridge -Ofast"
cmake --build build -j "${CPU_COUNT}"
install -v -m 0755 bin/* "${PREFIX}/bin"
