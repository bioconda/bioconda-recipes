#!/bin/bash

if [ `uname` == Darwin ]; then
    if mpic++ --show me | grep -q "clang++"; then
        # the openmpi package (and particularly the mpic++) from conda-forge is 
        # compiled to use clang++ (despl)
        # and the current package need an openmpi version based on gcc to use the
        # -fopenmpi version
        sed -i.bak "s|mpic++|g++ -I$PREFIX/include -L$PREFIX/lib -lmpi_cxx -lmpi|g" compiler.mk
    fi
fi

make clean
make all

mkdir -p $PREFIX/bin

tar xzf Disco_All_x86-Linux.tar.gz
cp Disco/buildG* $PREFIX/bin
cp Disco/fullsimplify $PREFIX/bin
cp Disco/parsimplify $PREFIX/bin
cp Disco/disco* $PREFIX/bin
cp Disco/run* $PREFIX/bin
