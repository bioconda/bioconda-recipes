#!/bin/bash
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin
make 
mv ropebwt2 $PREFIX/bin/
