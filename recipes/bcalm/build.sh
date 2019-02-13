#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# we can't build bcalm with avaible gatb, link trouble
rm -rf gatb-core
wget https://github.com/GATB/gatb-core/archive/v1.4.1.tar.gz
tar xvfz v1.4.1.tar.gz
mv gatb-core-1.4.1 gatb-core                                

# avoid gatb example install
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' -e "s/.*INSTALL.*examples.*/#&/" gatb-core/gatb-core/CMakeLists.txt
else
    sed -i'' -e "s/.*INSTALL.*examples.*/#&/" gatb-core/gatb-core/CMakeLists.txt
fi

# build 
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DKSIZE_LIST="32 64 96 128 160 192 224 256" ..
make -j 4
make install
