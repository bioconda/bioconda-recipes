#!/bin/bash

ifneq (,$(findstring Darwin,$(shell uname)))
	chmod 777 $PREFIX/include/c++
endif 

mkdir -p ${PREFIX}/bin

echo "~~~~~~~~~"
echo `ls ${PREFIX}`
echo "~~~~~~~~~"
echo `ls -lh ${PREFIX}/*/*`
echo "~~~~~~~~~"

make

cp -r bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
cp -r example ${PREFIX}
