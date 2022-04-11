#!/bin/bash

./compile

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/include/
mkdir -p ${PREFIX}/lib/

cp -r install/bin/* ${PREFIX}/bin/
cp -r install/include/* ${PREFIX}/include/
cp -r install/lib/* ${PREFIX}/lib/

# python wrappers:
pip install install/lib/btllib/python
