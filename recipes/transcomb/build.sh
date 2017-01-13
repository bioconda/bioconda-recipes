#!/bin/bash

mkdir -p $PREFIX/bin

sed -i .bak 's/<Path_To_BOOST_LIB_DIR>/${PREFIX}/lib/g' CMakeList.txt
sed -i .bak 's/<Path_To_BOOST_INCLUDE_DIR>/${PREFIX}/include/g' CMakeList.txt
sed -i .bak 's/<Path_To_BAMTOOLS_INCLUDE_DIR>/${PREFIX}/include/g' CMakeList.txt
sed -i .bak 's/<Path_To_BAMTOOLS_LIB_DIR>/${PREFIX}/lib/g' CMakeList.txt

mkdir build
cd build
cmake ../src
make
