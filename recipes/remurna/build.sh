#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

cd remuRNA

if [[ ${target_platform} == "linux-aarch64" ]]; then
  sed -i 's/\-m64/\-mabi=lp64/g' Makefile
fi
make

# Copy binery file since there is no INSTALL part in the makefile
cp -R remuRNA ${PREFIX}/bin
# Copy data folder. not sure if putting this folder in the main conda folder is "wise", but this tool won't work otherwise
cp -R data/ ${PREFIX}/lib
ln -s ${PREFIX}/lib/data ${PREFIX}/bin/data

# Preparing test files
printf ">gi|56682960|ref|NM_000146.3| Homo sapiens ferritin, light polypeptide (FTL), mRNA\nGCAGTTCGGCGGTCCCGCGGGTCTGTCTCTTGCTTCAACAGTGTTTGGACGGAACAGATCCGGGGACTCTCTTCCAGCCTCCGACCGCCCTCCGATTTCCTCTCCGCTTGCAACCTCCGGGACCATCTTCTCGGCCATCTCCTGCTTCTGGGACCTGCCAGCACCGTTTTTGTGGTTAGCTCCTTCTTGCCAACCAACCA\n*A3G" > input.fa
mv input.fa ${PREFIX}/bin/
