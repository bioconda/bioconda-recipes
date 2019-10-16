#!/bin/bash

python -m pip install --no-deps --ignore-installed .
gatk CreateSequenceDictionary -R $PREFIX/share/tbprofiler/tbdb.fasta
samtools faidx $PREFIX/share/tbprofiler/tbdb.fasta
