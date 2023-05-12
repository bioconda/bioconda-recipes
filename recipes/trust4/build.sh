#!/bin/bash

sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS} -I./samtools-0.1.19"
install -d "${PREFIX}/bin"
install trust4 fastq-extractor bam-extractor annotator run-trust4 \
    trust-simplerep.pl trust-barcoderep.pl trust-smartseq.pl trust-airr.pl \
    BuildDatabaseFa.pl BuildImgtAnnot.pl \
    "${PREFIX}/bin/"
