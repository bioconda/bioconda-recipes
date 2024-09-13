#!/bin/bash

set -xeuo

ls -la ${PREFIX}/include
ls -la ${PREFIX}/include/boost
ls -la ${PREFIX}/include/boost/iostreams
#export INCLUDES="-I${PREFIX}/include"
#export LIBPATH="-L${PREFIX}/lib"
#export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
#export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

mkdir -p ${PREFIX}/bin

# Disable CMake finding Boost
sed -i.bak -E 's/(FIND_PACKAGE\(Boost.*)/#\1/' CMakeLists.txt

cmake -S . -B build \
	-Wno-dev \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBOOST_ROOT="${PREFIX}"
cmake --build build -j ${CPU_COUNT} --verbose

cp -f ${SRC_DIR}/bin/bayesTyper ${PREFIX}/bin
cp -f ${SRC_DIR}/bin/bayesTyperTools ${PREFIX}/bin
cp -f ${SRC_DIR}/src/bayesTyperTools/scripts/* ${PREFIX}/bin
