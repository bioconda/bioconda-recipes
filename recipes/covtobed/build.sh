#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

echo "Compiling covtobed"
mkdir -p ${PREFIX}/bin

${CXX} -std=c++14 -O3 -I${PREFIX}/include -I${PREFIX}/include/bamtools -L${PREFIX}/lib *.cpp -o ${PREFIX}/bin/covtobed -lbamtools -lz
