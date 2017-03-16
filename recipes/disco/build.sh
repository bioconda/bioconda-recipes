#!/bin/bash

make clean
make all

mkdir -p $PREFIX/bin

tar xzf Disco_omp_x86-Linux.tar.gz
cp Disco/buildG* $PREFIX/bin
cp Disco/fullsimplify $PREFIX/bin
cp Disco/parsimplify $PREFIX/bin
cp Disco/disco* $PREFIX/bin
cp Disco/run* $PREFIX/bin
cp -r Disco/bbmap $PREFIX/bin