#!/bin/bash

cd src/mergeassembly
make
cd ../../
make

mkdir -p $PREFIX/bin
cp *.py $PREFIX/bin
cp *.sh $PREFIX/bin

binaries="\
ctgvalidate \
extract_fastqread \
fastatrans \
fastqtofasta \
FilterCtgCov \
mergeassembly \
mergefastq-p \
rfheader \
SCFtoCTG
"
for i in $binaries; do cp $i $PREFIX/bin; done