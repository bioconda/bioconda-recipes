#!/bin/bash -euo

g++ -O3 pdb2fasta.cpp -o pdb2fasta -static
mv pdb2fasta ${PREFIX}/bin
