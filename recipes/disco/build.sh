#!/bin/bash

make clean

g++ --version

if [ `uname` == Darwin ]; then
    if mpic++ --show | grep -q "clang++"; then
        # the openmpi package (and particularly the mpic++) from conda-forge is 
        # compiled to use clang++ (despl)
        # and the current package need an openmpi version based on gcc to use the
        # -fopenmpi version
        sed -i.bak "s|mpic++|g++ -I$PREFIX/include -L$PREFIX/lib -lmpi_cxx -lmpi|g" compiler.mk
    fi
    ln -s g++ $PREFIX/bin/g++
fi

g++ --version
export CC=$PREFIX/bin/gcc
export CXX=$PREFIX/bin/g++
export INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"
export LD_LIBRARY_PATH="$PREFIX/lib"

which make
make -C src/BuildGraph/Release READGZ=0 
make all

mkdir -p $PREFIX/bin

tar xzf Disco_All_x86-Linux.tar.gz
cp Disco/buildG* $PREFIX/bin
cp Disco/fullsimplify $PREFIX/bin
cp Disco/parsimplify $PREFIX/bin
cp Disco/disco* $PREFIX/bin
cp Disco/run* $PREFIX/bin
