#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib"
export LIBPATH="-L${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

sed -i.bak -e 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak -e 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak -e 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.16 FATAL_ERROR|VERSION 3.5|' CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2 FATAL_ERROR|VERSION 3.5|' deps/WFA/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2|VERSION 3.5|' deps/abPOA/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6 FATAL_ERROR|VERSION 3.5|' deps/libbf/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.8.11|VERSION 3.5|' deps/sdsl-lite/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.4.4|VERSION 3.5|' deps/sdsl-lite/external/libdivsufsort/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/sdsl-lite/external/googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/sdsl-lite/external/googletest/googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/sdsl-lite/external/googletest/googlemock/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.6|VERSION 3.5|' deps/sautocorr/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.1|VERSION 3.5|' deps/mmmulti/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2 FATAL_ERROR|VERSION 3.5|' deps/edlib/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.1|VERSION 3.5|' deps/atomicbitvector/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2|VERSION 3.5|' deps/args/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.8.11|VERSION 3.5|' deps/odgi/deps/sdsl-lite/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.4.4|VERSION 3.5|' deps/odgi/deps/sdsl-lite/external/libdivsufsort/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/odgi/deps/sdsl-lite/external/googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/odgi/deps/sdsl-lite/external/googletest/googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/odgi/deps/sdsl-lite/external/googletest/googlemock/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6 FATAL_ERROR|VERSION 3.5|' deps/odgi/deps/libbf/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2|VERSION 3.5|' deps/odgi/deps/args/CMakeLists.txt
rm -rf deps/spoa/*.bak
rm -rf deps/abPOA/*.bak
rm -rf deps/libbf/*.bak
rm -rf deps/sdsl-lite/*.bak
rm -rf *.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DEXTRA_FLAGS="-march=sandybridge -Ofast" -Wno-dev
cmake --build build -j "${CPU_COUNT}"
install -v -m 0755 bin/* "${PREFIX}/bin"
