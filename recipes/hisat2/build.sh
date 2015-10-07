#!/bin/bash

mkdir -p $PREFIX/bin

if [ $PY3K -eq 1 ]
then
    2to3 --write extract_exons.py extract_snps.py extract_splice_sites.py hisat2-build hisat2-inspect simulate_reads.py 
fi

for i in \
    hisat2 \
    hisat2-align-s \
    hisat2-align-l \
    hisat2-build \
    hisat2-build-s \
    hisat2-build-l \
    hisat2-inspect \
    hisat2-inspect-s \
    hisat2-inspect-l \
    extract_splice_sites.py \
    extract_snps.py \
    extract_exons.py \
    simulate_reads.py \
;do
    echo $i
    cp $i $PREFIX/bin
    chmod +x $PREFIX/bin/$i
done

cp -r example $PREFIX/bin

