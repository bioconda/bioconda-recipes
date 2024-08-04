#!/bin/bash -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include ${LDFLAGS}"

mkdir -p ${PREFIX}/bin

cmake -S . -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"

make -j ${CPU_COUNT}

cp -rf reads_categorizer clip_consensus_builder call_insertions dc_remapper add_filtering_info \
	filter normalise insurveyor.py random_pos_generator.py ${PREFIX}/bin/
