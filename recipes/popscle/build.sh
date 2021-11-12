#!/bin/bash


#For libhts:
#  - $ cmake -DHTS_INCLUDE_DIRS=/hts_absolute_path/include/  -DHTS_LIBRARIES=/hts_absolute_path/lib/libhts.a ..
#
#For bzip2:
#  - $ cmake -DBZIP2_INCLUDE_DIRS=/bzip2_absolute_path/include/ -DBZIP2_LIBRARIES=/bzip2_absolute_path/lib/libbz2.a ..
#
#For lzma:
#  - $ cmake -DLZMA_INCLUDE_DIRS=/lzma_absolute_path/include/ -DLZMA_LIBRARIES=/lzma_absolute_path/lib/liblzma.a ..

mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DZLIB_ROOT=$PREFIX \
      ..
make

mkdir -p "${PREFIX}/bin"
cp ../bin/popscle "${PREFIX}/bin/"
