#!/bin/bash
set -eu -o pipefail

mv temp_bwa/* bwa/
mv temp_fermi-lite/* fermi-lite/
mv temp_htslib/* htslib/

export CPP_INCLUDE_PATH="${PREFIX}/include"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LIBS="-lm ${PREFIX}/lib/libz.a"

./configure
make CC=${CC} CXXFLAGS="${CXXFLAGS} -fPIC" CFLAGS="${CFLAGS} -fPIC -L${PREFIX}/lib"
make install
make seqtools

mkdir -p ${PREFIX}/bin
cp bin/seqtools ${PREFIX}/bin/

mkdir -p ${PREFIX}/lib
cp lib/libseqlib.a ${PREFIX}/lib/
