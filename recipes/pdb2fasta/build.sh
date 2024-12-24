#!/bin/bash -euo

mkdir -p ${PREFIX}/bin
${CC} -O2 pdb2fasta.c -o pdb2fasta
mv pdb2fasta ${PREFIX}/bin
