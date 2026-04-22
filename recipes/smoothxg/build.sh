#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -g -I${PREFIX}/include -std=c++14 -Wno-deprecated-declarations -Wno-narrowing -Wno-unused-result"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

find deps -name "louds_tree.hpp" -exec sed -i 's/tree\.m_select1/tree.m_bv_select1/g' {} \;
find deps -name "louds_tree.hpp" -exec sed -i 's/tree\.m_select0/tree.m_bv_select0/g' {} \;

sed -i 's/__attribute__((__target__("arch=.*")))//g' deps/odgi/src/main.cpp

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
find deps -type f \( -name "CMakeLists.txt" -o -name "*.h" -o -name "*.cpp" \) -exec sed -i \
  -e 's/-msse4.2//g' \
  -e 's/-march=sandybridge//g' \
  -e 's/-march=native//g' \
  -e 's/-funroll-all-loops//g' \
  -e 's/-pipe//g' \
  {} \;
git clone https://github.com/DLTcollab/sse2neon.git
cp sse2neon/sse2neon.h deps/abPOA
sed -i '21s/<immintrin.h>/"..\/sse2neon.h"/' deps/abPOA/src/simd_instruction.h
sed -i '21s/<immintrin.h>/"..\/sse2neon.h"/' deps/abPOA/include/simd_instruction.h
sed -i 's/    -1, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,/    (char)-1, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,/g' deps/abPOA/src/abpoa_output.c
	
fi
find . -name "CMakeLists.txt" -exec sed -i 's/VERSION [[:digit:]]\.[[:digit:]]\+\(\| FATAL_ERROR\)/VERSION 3.5/g' {} \;

find . -name "*.bak" -delete


mkdir -p build
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_STANDARD=14 \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DOpenMP_C_FLAGS="-fopenmp" \
  -DOpenMP_CXX_FLAGS="-fopenmp" \
  -DOpenMP_omp_LIBRARY="${PREFIX}/lib/libomp.so" \
  -DSSE4_OPTIMIZATIONS=OFF \
  -DAVX2_OPTIMIZATIONS=OFF \
  -Wno-dev

cmake --build build -j "${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
install -v -m 755 $SRC_DIR/bin/* "${PREFIX}/bin"
