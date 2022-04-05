#!/bin/bash

./compile

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/include/
mkdir -p ${PREFIX}/lib/

cp bin/* ${PREFIX}/bin/
cp include/* ${PREFIX}/include/
cp lib/libbtllib.a ${PREFIX}/lib/libbtllib.a

# python wrappers:
