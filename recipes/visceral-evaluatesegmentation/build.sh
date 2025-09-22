#!/bin/bash


cd "source"
if [ $target_platform == "linux-aarch64" ];then

sed -i "s/VERSION 2.8/VERSION 3.5/g" CMakeLists.txt

fi
#sed -i "s/LESS 4 /LESS 5 /g" CMakeLists.txt
mkdir build
cd build

cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} 		\
    -D CMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
    -D CMAKE_BUILD_TYPE=Release 		\
    -D ITK_DIR=${PREFIX}/lib 			\
    ..

make -j

cp EvaluateSegmentation ${PREFIX}/bin/EvaluateSegmentation
