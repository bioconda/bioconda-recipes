#!/bin/bash -euo

set -x

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

# Delete call to `git rev-parse HEAD`
# https://github.com/bioinformatics-centre/BayesTyper/blob/1b04081ca4c64975270d267dbe9d80bd00bddaf9/CMakeLists.txt#L4-L9
sed -i.bak "4d;5d;6d;7d;8d;9d" CMakeLists.txt

# include boost from the library path, not from local in all *.cpp/*.hpp files
#find ./ -name "*.?pp" | xargs sed -i.bak -E 's/#include "boost(.*)"/#include <boost\1>/'

# Disable CMake finding Boost
sed -i.bak -E 's/(FIND_PACKAGE\(Boost.*)/#\1/' CMakeLists.txt

mkdir -p ${PREFIX}/bin

cmake -S . -B build \
	-Wno-dev \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DGIT_LAST_COMMIT_HASH=123456
cmake --build build -j ${CPU_COUNT} --verbose

cp -f ${SRC_DIR}/bin/bayesTyper ${PREFIX}/bin
cp -f ${SRC_DIR}/bin/bayesTyperTools ${PREFIX}/bin
cp -f ${SRC_DIR}/src/bayesTyperTools/scripts/* ${PREFIX}/bin
