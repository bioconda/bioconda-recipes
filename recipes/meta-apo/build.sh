#!/bin/bash
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/databases

make 

cp -r bin/* ${PREFIX}/bin
cp -r databases/* ${PREFIX}/databases
