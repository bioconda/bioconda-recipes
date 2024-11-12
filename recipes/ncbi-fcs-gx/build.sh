#!/bin/bash -e
set -uex

mkdir -vp ${PREFIX}/bin

make VERBOSE=1 -j ${CPU_COUNT}

cp $SRC_DIR/build/src/gx    ${PREFIX}/bin/
cp $SRC_DIR/scripts/*      ${PREFIX}/bin/
cp $SRC_DIR/make_gxdb/blast_names_mapping.tsv ${PREFIX}/bin/ 

chmod ua+x ${PREFIX}/bin/gx

