#!/bin/bash

make CXX="${CXX} ${CXXFLAGS} -std=c++03 ${CPPFLAGS} ${LDFLAGS}"

cd bin

install -d "${PREFIX}/bin"
install \
    2csfastq_1csfastq \
    cd-hit-est \
    cs2bs_assembly \
    csfasta_to_fastq \
    fasta_remove \
    pass \
    rename_fastq_tag \
    satrap \
    "${PREFIX}/bin/"
