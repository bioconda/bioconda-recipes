#!/bin/bash

set -xe

if [ "$(uname -m)" == "x86_64" ]; then
sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
fi

make -j ${CPU_COUNT} \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS} -I./samtools-0.1.19"
install -d "${PREFIX}/bin"
install trust4 fastq-extractor bam-extractor annotator run-trust4 \
    trust-simplerep.pl trust-barcoderep.pl trust-smartseq.pl trust-airr.pl \
    BuildDatabaseFa.pl BuildImgtAnnot.pl \
    "${PREFIX}/bin/"
