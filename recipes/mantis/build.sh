#!/bin/bash

# build sdsl-lite for static linking (required as c++17 is required - conda-forge is c++14)
wget https://github.com/simongog/sdsl-lite/releases/download/v2.1.1/sdsl-lite-2.1.1.tar.gz.offline.install.gz
tar xf sdsl-lite-2.1.1.tar.gz.offline.install.gz
pushd sdsl-lite-2.1.1
mkdir $SRC_DIR/sdsl-build
CXXFLAGS="${CXXFLAGS} -std=gnu++1z"
./install.sh $SRC_DIR/sdsl-build
popd

# build mantis
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DSDSL_INSTALL_PATH=$SRC_DIR/sdsl-build .. # pass -DNH=1 to disable Haswell instructions
make install VERBOSE=1
popd
