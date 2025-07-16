#!/bin/bash

mkdir -p ${PREFIX}/bin

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP ${LDFLAGS}"

cp -r databases ${PREFIX}
cp -r example ${PREFIX}
