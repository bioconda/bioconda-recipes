#!/bin/bash
sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
sed -i.bak 's/\$WD\/samtools-0.1.19\/samtools/samtools/' psiclass
make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS} -I./samtools-0.1.19"
install -d "${PREFIX}/bin"
install \
    psiclass \
    classes \
    junc \
    trust-splice \
    subexon-info \
    combine-subexons \
    vote-transcripts \
    add-genename \
    FilterSplice.pl \
    "${PREFIX}/bin/"
