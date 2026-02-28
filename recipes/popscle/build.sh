#!/bin/bash

mkdir -p "${PREFIX}/bin"

sed -i.bak 's/cmake_minimum_required(VERSION 2\.8\.4)/cmake_minimum_required(VERSION 3.5)/g' CMakeLists.txt
sed -i.bak '1i #include <random>' cmd_cram_freemuxlet.cpp
sed -i.bak '304i     std::random_device rd;\n    std::mt19937 g(rd());' cmd_cram_freemuxlet.cpp
sed -i.bak 's/std::random_shuffle(orand.begin(), orand.end())/std::shuffle(orand.begin(), orand.end(), g)/g' cmd_cram_freemuxlet.cpp
sed -i.bak '28i #include <limits>' gtf_interval_tree.h
sed -i.bak '1i #include <cstdint>' gtf.h

#For libhts:
#  - $ cmake -DHTS_INCLUDE_DIRS=/hts_absolute_path/include/  -DHTS_LIBRARIES=/hts_absolute_path/lib/libhts.a ..
#
#For bzip2:
#  - $ cmake -DBZIP2_INCLUDE_DIRS=/bzip2_absolute_path/include/ -DBZIP2_LIBRARIES=/bzip2_absolute_path/lib/libbz2.a ..
#
#For lzma:
#  - $ cmake -DLZMA_INCLUDE_DIRS=/lzma_absolute_path/include/ -DLZMA_LIBRARIES=/lzma_absolute_path/lib/liblzma.a ..

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_CXX_COMPILER="${CXX}" \
      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DZLIB_ROOT="$PREFIX"

cmake --build build -j "${CPU_COUNT}"

install bin/popscle "${PREFIX}/bin"
