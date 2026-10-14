#!/bin/bash

python -m pip install --no-deps --ignore-installed .
cd db
samtools  dict who_v2+/genome.fasta -o who_v2+/genome.dict
samtools faidx who_v2+/genome.fasta
bwa index who_v2+/genome.fasta
python ../tb-profiler load_library who_v2+ --force
