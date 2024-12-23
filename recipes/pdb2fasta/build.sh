#!/bin/bash -euo

${CXX} -O3 pdb2fasta.cpp -o pdb2fasta -static
mv pdb2fasta ${PREFIX}/bin
