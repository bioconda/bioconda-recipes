#!/bin/bash -e
# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --path $SRC_DIR/mtsv/ext/ --root $PREFIX

##strictly use anaconda build environment to compile taxidtool
CXX=${PREFIX}/bin/g++
#to fix problems with zlib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
$GXX -std=c++11 -pthread $SRC_DIR/mtsv/mtsv_prep/taxidtool.cpp -o mtsv-db-build
mkdir -p ${PREFIX}/bin
cp mtsv-db-build ${PREFIX}/bin


$PYTHON setup.py install --single-version-externally-managed --record=record.txt
