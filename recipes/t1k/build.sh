#!/bin/bash

set -xe

if [[ "$(uname -m)" == "aarch64" ]]; then
    export CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
LINKPATH="${LDFLAGS}"
if [[ "$(uname -m)" == "x86_64" ]]; then
    # use samtools 0.1.19 as a dependency
    sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
    rm -rf *.bak
else
    # build the vendored samtools 0.1.19
    sed -i.bak 's/cd samtools-0.1.19 ; make /cd samtools-0.1.19 ; make CC="${CC}" CFLAGS="${CFLAGS} -L${PREFIX}\/lib" LDFLAGS="${LDFLAGS}" LIBPATH="-L${PREFIX}\/lib"/' Makefile
    rm -rf *.bak
    LINKPATH="${LDFLAGS} -I./samtools-0.1.19 -L./samtools-0.1.19"
fi

make -j"${CPU_COUNT}" \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LINKPATH}"
install -d "${PREFIX}/bin"
install -v -m 0755 genotyper analyzer fastq-extractor bam-extractor run-t1k \
    t1k-build.pl ParseDatFile.pl AddGeneCoord.pl t1k-smartseq.pl t1k-merge.py \
    "${PREFIX}/bin"
