#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# we can't build bcalm with avaible gatb, link trouble
rm -rf gatb-core
git clone https://github.com/GATB/gatb-core.git
cd gatb-core
git checkout f25f57bb65db0870ec3c5b14af5e694c7941f567
cd ..

# avoid gatb example install
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' -e "s/.*INSTALL.*examples.*/#&/" gatb-core/gatb-core/CMakeLists.txt
else
    sed -i'' -e "s/.*INSTALL.*examples.*/#&/" gatb-core/gatb-core/CMakeLists.txt
fi

# build 
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DKSIZE_LIST="32 64 96 128 160 192" ..
make
make install
