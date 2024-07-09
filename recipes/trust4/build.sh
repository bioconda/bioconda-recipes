#!/bin/bash

set -xe

if [ "$(uname -m)" == "x86_64" ]; then
    # use samtools 0.1.19 as a dependency
    sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
else
    # build the vendored samtools 0.1.19
    sed -i.bak 's/cd samtools-0.1.19 ; make /cd samtools-0.1.19 ; make CC="${CC}" CFLAGS="${CFLAGS} -L${PREFIX}\/lib" LDFLAGS="${LDFLAGS}" LIBPATH="-L${PREFIX}\/lib"/' Makefile
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
