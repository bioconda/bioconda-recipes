#!/bin/bash

make

path='bin/' 

if [ "$(uname)" == "Darwin" ]; then
    path='bin/MAC_OSX_bin/'
fi
cd $path
binaries="2csfastq_1csfastq \
            cd-hit-est \
            cs2bs_assembly \
            csfasta_to_fastq \
            fasta_remove \
            pass \
            rename_fastq_tag \
            satrap"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
