#!/bin/bash
pushd src
sed -i.bak '4iCFLAGS += -I$(PREFIX)/include -L$(PREFIX)/lib' Makefile
make CC=${CXX}
mkdir -p ${PREFIX}/bin
mv psascan ${PREFIX}/bin/
