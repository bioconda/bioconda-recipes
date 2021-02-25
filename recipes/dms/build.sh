#!/bin/bash

mkdir -p ${PREFIX}/bin

echo "~~~~~~~~~"
echo `ls ${PREFIX}`
echo "~~~~~~~~~"
echo `ls ${PREFIX}/*`
echo "~~~~~~~~~"

make

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
cp -r example ${PREFIX}
