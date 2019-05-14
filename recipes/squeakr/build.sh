#!/bin/bash

BUILD_OS=$(uname -s)

if [ ${BUILD_OS} == "Darwin" ]; then
   LDFLAGS="${LDFLAGS} -stdlib=libc++ -L ${PREFIX}/lib -Ofast -lpthread -lboost_system -lboost_thread -lm -lbz2 -lz -lrt" CXXFLAGS="-stdlib=libc++ -I ${PREFIX}/include" NH=1 make
   else
   LDFLAGS="${LDFLAGS} -L ${PREFIX}/lib -Ofast -lpthread -lboost_system -lboost_thread -lm -lbz2 -lz -lrt" CXXFLAGS="${CXXFLAGS} -L ${PREFIX}/lib -I ${PREFIX}/include" NH=1 make
fi

install -d $PREFIX/bin
install squeakr $PREFIX/bin
