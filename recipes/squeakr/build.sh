#!/bin/bash

BUILD_OS=$(uname -s)

if [ ${BUILD_OS} == "Darwin" ]; then
   CXX="${CXX}" LDFLAGS="${LDFLAGS} -stdlib=libc++ -L ${PREFIX}/lib" CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -I ${PREFIX}/include" NH=1 make
   else
   CXX="${CXX}" LDFLAGS="${LDFLAGS} -L ${PREFIX}/lib" CXXFLAGS="${CXXFLAGS} -L ${PREFIX}/lib -I ${PREFIX}/include" NH=1 make
fi

install -d $PREFIX/bin
install squeakr $PREFIX/bin
