#!/bin/sh

mkdir bin
cd src
make
cd ..

cp ${SRC_DIR}/src/FamSeq $PREFIX/bin/FamSeq 
