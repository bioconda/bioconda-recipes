#!/bin/bash
sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/0/' Makefile
make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS}"
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
    "${PREFIX}/bin/"
