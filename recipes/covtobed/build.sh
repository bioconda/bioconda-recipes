#!/bin/bash

echo "Compiling covtobed"
mkdir -p ${PREFIX}/bin
#$CXX -std=c++11 *.cpp  ${PREFIX}/lib/libbamtools.a -o covtobed -lz
$CXX -std=c++11 -O3 -I${PREFIX}/include/ -I${BUILD_PREFIX}/include -I${PREFIX}/include/bamtools -L${PREFIX}/lib *.cpp -o ${PREFIX}/bin/covtobed -lbamtools -lz
