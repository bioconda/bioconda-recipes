#!/bin/bash


mkdir -p ${PREFIX}/bin

make 

cp -r bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
cp -r example ${PREFIX}
