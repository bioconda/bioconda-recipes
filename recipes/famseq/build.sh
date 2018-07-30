#!/bin/sh

cd FamSeq/src
make
mkdir -p ${PREFIX}/bin
mv FamSeq $PREFIX/bin/FamSeq 
