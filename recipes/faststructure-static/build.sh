#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PREFIX}/lib
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

cp vars/*.h .
cp vars/*.pxd .
cp vars/*.pyx .
cp vars/*.c .

python setup.py build_ext --inplace

mkdir -p ${PREFIX}/bin/fastStructure
mv * ${PREFIX}/bin/fastStructure
