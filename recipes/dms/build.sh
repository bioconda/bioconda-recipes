#!/bin/bash

#if [ x"$(uname)" == x"Darwin" ]; then
#        chmod 777 $PREFIX/include/c++
#fi

mkdir -p ${PREFIX}/bin

make

cp -r databases ${PREFIX}
cp -r example ${PREFIX}
