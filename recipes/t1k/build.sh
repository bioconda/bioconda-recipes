#!/bin/bash

sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS} -I./samtools-0.1.19"
install -d "${PREFIX}/bin"
install genotyper analyzer fastq-extractor bam-extractor run-t1k \
    t1k-build.pl ParseDatFile.pl AddGeneCoord.pl t1k-smartseq.pl t1k-merge.py \
    "${PREFIX}/bin/"
