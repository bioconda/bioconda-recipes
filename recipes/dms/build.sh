#!/bin/bash

export DynamicMetaStorms=${PREFIX}

mkdir -p ${PREFIX}/bin

make CXX="${CXX} -fopenmp -O3 -I${PREFIX}/include/ -I${BUILD_PREFIX}/include -I${PREFIX}/include -L${PREFIX}/lib -lpthread"

cp -r databases ${PREFIX}
cp -r example ${PREFIX}
