#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# we can't build bcalm with avaible gatb, link trouble
rm -rf gatb-core
git clone https://github.com/GATB/gatb-core.git
cd gatb-core
git checkout d053d0dffdfb9d31e45d42a3da49d2f71c8f87b3
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
