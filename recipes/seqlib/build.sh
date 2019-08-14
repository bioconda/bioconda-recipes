#!/bin/bash
set -eu -o pipefail

mv temp_bwa/* bwa/
mv temp_fermi-lite/* fermi-lite/
mv temp_htslib/* htslib/

export LIBS="-lz ${PREFIX}/lib/libz.a"

./configure
make CC=${CC} CXXFLAGS="${CXXFLAGS} -fPIC" CFLAGS="${CFLAGS} -fPIC"
make install
make seqtools

mkdir -p ${PREFIX}/bin
cp bin/seqtools ${PREFIX}/bin/

mkdir -p ${PREFIX}/lib
cp lib/libseqlib.a ${PREFIX}/lib/
