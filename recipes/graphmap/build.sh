#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Installing GraphMap for OSX."
    make deps
    make mac
    cp bin/Mac/graphmap $PREFIX/bin
else 
    echo "Installing GraphMap for UNIX/Linux."
    make deps
    make 
    cp bin/Linux-x64/graphmap $PREFIX/bin 
fi

