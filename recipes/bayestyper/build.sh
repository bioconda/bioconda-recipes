#!/bin/bash -euo

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

# Delete call to `git rev-parse HEAD`
# https://github.com/bioinformatics-centre/BayesTyper/blob/1b04081ca4c64975270d267dbe9d80bd00bddaf9/CMakeLists.txt#L4-L9
sed -i.bak "4d;5d;6d;7d;8d;9d" CMakeLists.txt

mkdir -p ${PREFIX}/bin
mkdir build && cd build

cmake -S .. -B . \
	-Wno-dev \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DGIT_LAST_COMMIT_HASH=123456
make -j ${CPU_COUNT}

cp -f ${SRC_DIR}/bin/bayesTyper ${PREFIX}/bin
cp -f ${SRC_DIR}/bin/bayesTyperTools ${PREFIX}/bin
cp -f ${SRC_DIR}/src/bayesTyperTools/scripts/* ${PREFIX}/bin
