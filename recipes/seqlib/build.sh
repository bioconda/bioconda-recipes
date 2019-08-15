#!/bin/bash
set -eu -o pipefail

mv temp_bwa/* bwa/
mv temp_fermi-lite/* fermi-lite/
mv temp_htslib/* htslib/

export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure
make CC=${CC} CXXFLAGS="${CXXFLAGS} -fPIC -L${PREFIX}/lib" CFLAGS="${CFLAGS} -fPIC -L${PREFIX}/lib"
make install
make seqtools

mkdir -p ${PREFIX}/bin
cp bin/seqtools ${PREFIX}/bin/

mkdir -p ${PREFIX}/lib
cp lib/libseqlib.a ${PREFIX}/lib/
