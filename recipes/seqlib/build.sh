#!/bin/bash
set -eu -o pipefail

mv temp_bwa/* bwa/
mv temp_fermi-lite/* fermi-lite/
mv temp_htslib/* htslib/

./configure
make CC=${CC} -fPIC
make install
make seqtools

mkdir -p ${PREFIX}/bin
cp bin/seqtools ${PREFIX}/bin/

mkdir -p ${PREFIX}/lib
cp lib/libseqlib.a ${PREFIX}/lib/
