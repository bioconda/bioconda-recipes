#!/bin/bash -euo

mkdir -p ${PREFIX}/bin
${CXX} ${CXXFLAGS} -static pdb2fasta.cpp -o pdb2fasta
mv pdb2fasta ${PREFIX}/bin
