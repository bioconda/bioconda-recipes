#!/bin/bash -euo

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/bin
mkdir build && cd build

cmake -S .. -B ./ \
	-DBUILD_SCRIPTS=1 \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
make -j ${CPU_COUNT}

cp -f ${SRC_DIR}/bin/bayesTyper ${PREFIX}/bin
cp -f ${SRC_DIR}/bin/bayesTyperTools ${PREFIX}/bin
cp -f ${SRC_DIR}/src/bayesTyperTools/scripts/* ${PREFIX}/bin
