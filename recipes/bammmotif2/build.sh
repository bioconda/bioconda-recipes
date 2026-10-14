#!/usr/bin/env bash
set -euxo pipefail

# Upstream v2.0 has CMakeLists.txt formatted as a single long line, so a
# normal multi-line patch is fragile. Keep these conda-specific edits here.
sed -i.bak \
  -e 's/cmake_minimum_required (VERSION 2.8.11 FATAL_ERROR)/cmake_minimum_required (VERSION 3.5 FATAL_ERROR)/' \
  -e 's/set (Boost_USE_STATIC_LIBS ON CACHE BOOL "use static libraries from Boost")/set (Boost_USE_STATIC_LIBS OFF CACHE BOOL "use shared libraries from Boost")/' \
  -e 's/include_directories (${Boost_INCLUDEDIR})/include_directories (${Boost_INCLUDE_DIRS})/' \
  -e 's/set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")/set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")/' \
  CMakeLists.txt

# Fail early if any expected replacement did not happen.
grep -q 'cmake_minimum_required (VERSION 3.5 FATAL_ERROR)' CMakeLists.txt
grep -q 'Boost_USE_STATIC_LIBS OFF' CMakeLists.txt
grep -q 'Boost_INCLUDE_DIRS' CMakeLists.txt
grep -q 'CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall"' CMakeLists.txt

mkdir -p build
cd build

cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  ..

make -j"${CPU_COUNT}"
make install

test -x "${PREFIX}/bin/BaMMmotif"
test -x "${PREFIX}/bin/BaMMScan"
test -x "${PREFIX}/bin/FDR"
