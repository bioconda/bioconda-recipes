#!/bin/bash
set -eu -o pipefail

cd temp_htslib
git checkout 5163833ede355f8c2a6788780c55d7598279e767
cd ..

mv temp_bwa/* bwa/
mv temp_fermi-lite/* fermi-lite/
mv temp_htslib/* htslib/

./configure
make
make install
make seqtools

mkdir -p ${PREFIX}/bin
cp bin/seqtools ${PREFIX}/bin/

mkdir -p ${PREFIX}/lib
cp lib/libseqlib.a ${PREFIX}/lib/
