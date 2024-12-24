#!/bin/bash -euo

mkdir -p ${PREFIX}/bin
${CC} ${CFLAGS} pdb2fasta.cpp -o pdb2fasta
mv pdb2fasta ${PREFIX}/bin
