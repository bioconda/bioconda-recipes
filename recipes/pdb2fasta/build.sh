#!/bin/bash -euo

mkdir -p ${PREFIX}/bin
${CC} ${CFLAGS} pdb2fasta.c -o pdb2fasta
mv pdb2fasta ${PREFIX}/bin
