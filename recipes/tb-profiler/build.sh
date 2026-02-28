#!/bin/bash

python -m pip install --no-deps --ignore-installed .
cd db
samtools  dict tbdb/genome.fasta -o tbdb/genome.dict
samtools faidx tbdb/genome.fasta
bwa index tbdb/genome.fasta
python ../tb-profiler load_library tbdb --force
