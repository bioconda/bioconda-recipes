#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wall"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

cd src/SpliceMap-src
make install CC="${CXX}" CFLAGS-64="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 SpliceMap \
  runSpliceMap \
  sortsam \
  nnrFilter \
  neighborFilter \
  uniqueJunctionFilter \
  randomJunctionFilter \
  wig2barwig \
  colorJunction \
  subseq \
  findNovelJunctions \
  statSpliceMap \
  countsam \
  amalgamateSAM \
  precipitateSAM \
  "${PREFIX}/bin"
