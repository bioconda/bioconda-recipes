#!/bin/bash

python -m pip install --no-deps --ignore-installed .
gatk CreateSequenceDictionary -R $PREFIX/share/tbprofiler/tbdb.fasta
samtools faidx $PREFIX/share/tbprofiler/tbdb.fasta
bwa index $PREFIX/share/tbprofiler/tbdb.fasta
# this downloads Mycobacterium_tuberculosis_h37rv DB to $PREFIX/share/snpeff-SNPEFF_VERSION/data
snpEff download Mycobacterium_tuberculosis_h37rv
