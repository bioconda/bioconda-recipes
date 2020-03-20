#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin
cd $SRC_DIR
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing FaQCs for OSX."
    make CC=$CXX OPENMP=""
    cp FaQCs $PREFIX/bin
else 
    echo "Installing FaQCs for UNIX/Linux."
    make CC=$CXX
    cp FaQCs $PREFIX/bin
fi
