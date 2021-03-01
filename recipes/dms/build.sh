#!/bin/bash

#if [ x"$(uname)" == x"Darwin" ]; then
#        chmod 777 $PREFIX/include/c++
#fi

mkdir -p ${PREFIX}/bin

echo "~~~~~~~~~"
echo `ls ${PREFIX}`
echo "~~~~~~~~~"
echo `ls ${PREFIX}/*`
echo "~~~~~~~~~"

make --enable-shared --enable-static

cp -r bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
cp -r example ${PREFIX}
