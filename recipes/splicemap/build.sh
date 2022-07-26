#!/bin/bash

cd src/SpliceMap-src
make install CC="${CXX}" CFLAGS-64="${CXXFLAGS} -m64 -O3 -Wall"

mkdir -p "${PREFIX}/bin"
cp \
  SpliceMap \
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
  "${PREFIX}/bin/"
