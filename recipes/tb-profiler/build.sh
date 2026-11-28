#!/bin/bash

python -m pip install --no-deps --ignore-installed .
cd db
samtools  dict who_v3/genome.fasta -o who_v3/genome.dict
samtools faidx who_v3/genome.fasta
bwa index who_v3/genome.fasta
python ../tb-profiler load_library who_v3 --force
