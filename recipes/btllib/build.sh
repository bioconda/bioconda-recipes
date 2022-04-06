#!/bin/bash

./compile

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/include/
mkdir -p ${PREFIX}/lib/

cp install/bin/* ${PREFIX}/bin/
cp install/include/* ${PREFIX}/include/
cp install/lib/* ${PREFIX}/lib/

# python wrappers:
