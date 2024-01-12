#!/bin/bash -e
set -uex

mkdir -vp ${PREFIX}/bin

ls -l .

$GCC --version
$GCC -print-search-dirs 

#cd fcs-gx-0.4.0
make VERBOSE=1 

cp $SRC_DIR/build/src/gx    ${PREFIX}/bin/
cp $SRC_DIR/scripts/*      ${PREFIX}/bin/
cp $SRC_DIR/make_gxdb/blast_names_mapping.tsv ${PREFIX}/bin/ 
echo PREFIX: ${PREFIX}
chmod ua+x ${PREFIX}/bin/gx

