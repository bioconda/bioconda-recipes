#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make

mkdir -p $PREFIX/bin
cp src/ALE $PREFIX/bin
cp src/synthReadGen $PREFIX/bin
for f in src/*.py ; 
do
    sed -i.bak "s:/usr/bin/python:/usr/bin/env python:" $f
done
cp src/*.py $PREFIX/bin
chmod a+x ${PREFIX}/bin/*.py
