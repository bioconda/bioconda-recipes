#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ "$(uname)" == "Darwin" ]; then
    echo "Installing FaQCs for OSX."
    mkdir -p $PREFIX/bin
    cp bin/MacOSX_x86_64/* $PREFIX/bin
else 
    echo "Installing FaQCs for UNIX/Linux."
    make
    mkdir -p $PREFIX/bin
    cp FaQCs $PREFIX/bin
fi
