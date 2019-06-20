#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib


make clean
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ `uname` == Darwin ]; then
    if mpic++ --show | grep -q "clang++"; then
        # the openmpi package (and particularly the mpic++) from conda-forge is 
        # compiled to use clang++ (despl)
        # and the current package need an openmpi version based on gcc to use the
        # -fopenmpi version
        sed -i.bak "s|mpic++|g++ -I$PREFIX/include -L$PREFIX/lib -lmpi_cxx -lmpi|g" compiler.mk
    fi
fi

make all

mkdir -p $PREFIX/bin

tar xzf Disco_All_x86-Linux.tar.gz
cp Disco/buildG* $PREFIX/bin
cp Disco/fullsimplify $PREFIX/bin
cp Disco/parsimplify $PREFIX/bin
cp Disco/disco* $PREFIX/bin
cp Disco/run* $PREFIX/bin
