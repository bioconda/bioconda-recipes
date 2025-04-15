#!/bin/bash -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include ${LDFLAGS}"

mkdir -p ${PREFIX}/bin

cmake -S . -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"

${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} reads_categorizer.cpp -o reads_categorizer -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} clip_consensus_builder.cpp -o clip_consensus_builder -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} libs/ssw.c libs/ssw_cpp.cpp call_insertions.cpp -o call_insertions -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} libs/ssw.c libs/ssw_cpp.cpp dc_remapper.cpp -o dc_remapper -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} add_filtering_info.cpp -o add_filtering_info -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} filter.cpp -o filter -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} normalise.cpp -o normalise -pthread -lhts

cp -rf reads_categorizer clip_consensus_builder call_insertions dc_remapper add_filtering_info \
	filter normalise insurveyor.py random_pos_generator.py ${PREFIX}/bin/
