#!/bin/bash

mkdir -p ${PREFIX}/bin

make CC=$CXX
cp bin/qgrs ${PREFIX}/bin
chmod +x ${PREFIX}/bin/qgrs
