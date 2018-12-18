#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
cp fml-asm ${PREFIX}/bin
cp *.h ${PREFIX}/include
