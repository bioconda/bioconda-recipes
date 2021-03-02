#!/bin/bash

#if [ x"$(uname)" == x"Darwin" ]; then
#        chmod 777 $PREFIX/include/c++
#fi

mkdir -p ${PREFIX}/bin

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP ${LDFLAGS}"

cp -r databases ${PREFIX}
cp -r example ${PREFIX}
