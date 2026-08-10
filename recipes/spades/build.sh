#!/bin/bash
set -e -o pipefail -x

export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -fcommon -Wno-deprecated-declarations -Wno-unused-variable -Wno-parentheses -Wno-unused-result -Wno-unused-but-set-variable -Wno-conversion"

PREFIX="${PREFIX}" ./spades_compile.sh -rj"${CPU_COUNT}"

cd ${PREFIX}/bin

"${STRIP}" spades-bwa binspreader \
  spades-corrector-core spades-hammer \
  spades-hpc spades-ionhammer \
  pathracer pathracer-seq-fs \
  spades-core spades-convert-bin-to-fasta \
  spades-gbuilder spades-gmapper \
  spades-gsimplifier spades-kmercount \
  spades-read-filter spades-kmer-estimating \
  spades-gfa-split spaligner
