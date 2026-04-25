#!/bin/bash
set -e

make clean || true

mkdir -p ${PREFIX}/bin

ln -s ${CXX} ./g++
export PATH=$(pwd):$PATH

export CFLAGS="${CFLAGS} -I${PREFIX}/include -fpermissive -Wall "
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -fpermissive -Wall"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CXX}" \
     CXX="${CXX}" \
     CFLAGS="${CFLAGS}" \
     CXXFLAGS="${CXXFLAGS}" \
     LDFLAGS="${LDFLAGS}" \
     LIBS="-L${PREFIX}/lib -lm -lz -lpthread ./libminimap2.a" \
     VERBOSE=1

install -m 0755 HapFold ${PREFIX}/bin/HapFold
ln -sf HapFold ${PREFIX}/bin/hapfold
