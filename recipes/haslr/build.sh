#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make haslr
mkdir -p ${PREFIX}/bin
cp -f bin/haslr_assemble bin/haslr.py bin/minia_nooverlap ${PREFIX}/bin

