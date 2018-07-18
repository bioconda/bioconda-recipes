#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

make clean

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
cp buildG* $PREFIX/bin
cp fullsimplify $PREFIX/bin
cp parsimplify $PREFIX/bin
cp disco* $PREFIX/bin
cp run* $PREFIX/bin
