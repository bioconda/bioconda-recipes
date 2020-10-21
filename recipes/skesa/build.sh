#!/bin/bash

export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

makefile="Makefile.nongs"

if [ "$(uname)" == "Darwin" ]; then
  sed -i.bak 's/-Wl,-Bstatic//' $makefile
  sed -i.bak 's/-Wl,-Bdynamic -lrt//' $makefile
fi

make -f $makefile BOOST_PATH=${PREFIX} CC="$CXX $CXXFLAGS"

mkdir -p ${PREFIX}/bin
mv skesa ${PREFIX}/bin/
