#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Installing FaQCs for OSX."
    make OPENMP=""
    cp FaQCs $PREFIX/bin
else 
    echo "Installing FaQCs for UNIX/Linux."
    make
    cp FaQCs $PREFIX/bin
fi
