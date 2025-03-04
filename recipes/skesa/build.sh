#!/bin/bash

set -xe

export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

if [ "$(uname)" == "Darwin" ]; then
  sed -i.bak 's/-Wl,-Bstatic//' Makefile.nongs
  sed -i.bak 's/-Wl,-Bdynamic -lrt//' Makefile.nongs
fi

LDFLAGS=-L${PREFIX}/lib

make -f Makefile.nongs \
    BOOST_PATH=${PREFIX} \
    CC="$CXX -std=c++11 $CXXFLAGS" \
    LDFLAGS=$LDFLAGS

mkdir -p ${PREFIX}/bin
mv skesa ${PREFIX}/bin/
mv saute ${PREFIX}/bin/
mv saute_prot ${PREFIX}/bin/
mv gfa_connector ${PREFIX}/bin/
mv kmercounter ${PREFIX}/bin/
