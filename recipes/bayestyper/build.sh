#!/bin/bash

set -xeuo

ls -la ${PREFIX}/include/boost/iostreams
#export INCLUDES="-I${PREFIX}/include"
#export LIBPATH="-L${PREFIX}/lib"
#export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

mkdir -p ${PREFIX}/bin

cmake -S . -B build \
	-Wno-dev \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
cmake --build build -j ${CPU_COUNT} --verbose

cp -f ${SRC_DIR}/bin/bayesTyper ${PREFIX}/bin
cp -f ${SRC_DIR}/bin/bayesTyperTools ${PREFIX}/bin
cp -f ${SRC_DIR}/src/bayesTyperTools/scripts/* ${PREFIX}/bin
