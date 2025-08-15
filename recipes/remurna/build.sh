#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/remurna

cd remuRNA

if [[ ${target_platform} == "linux-aarch64" ]]; then
	sed -i.bak 's/\-m64/\-mabi=lp64/g' Makefile
fi

make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

# Copy binery file since there is no INSTALL part in the makefile
install -v -m 755 remuRNA ${PREFIX}/bin
# Copy data folder. not sure if putting this folder in the main conda folder is "wise", but this tool won't work otherwise
cp -Rf data/ ${PREFIX}/share/remurna
ln -sf ${PREFIX}/share/remurna/data ${PREFIX}/bin/data

# Preparing test files
printf ">gi|56682960|ref|NM_000146.3| Homo sapiens ferritin, light polypeptide (FTL), mRNA\nGCAGTTCGGCGGTCCCGCGGGTCTGTCTCTTGCTTCAACAGTGTTTGGACGGAACAGATCCGGGGACTCTCTTCCAGCCTCCGACCGCCCTCCGATTTCCTCTCCGCTTGCAACCTCCGGGACCATCTTCTCGGCCATCTCCTGCTTCTGGGACCTGCCAGCACCGTTTTTGTGGTTAGCTCCTTCTTGCCAACCAACCA\n*A3G" > input.fa
mv input.fa ${PREFIX}/bin/
