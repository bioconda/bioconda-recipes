#!/bin/bash


mkdir -p ${PREFIX}/bin

make 

cp -r bin/* ${PREFIX}/bin
cp -r example ${PREFIX}
