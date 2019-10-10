#!/bin/bash

cd src;
make CC=${CXX} CFLAGS="$CXXFLAGS -fopenmp -lz"


mkdir -p $PREFIX/bin;
cp src/path_counter Bwise_path_counter;
cp src/path_to_kmer Bwise_path_to_kmer;
cp src/maximal_sr Bwise_maximal_sr;
cp src/K2000/K2000.py Bwise_K2000.py;
cp src/K2000/K2000_msr_to_gfa.py Bwise_K2000_msr_to_gfa.py;
cp src/K2000/K2000_gfa_to_fasta.py Bwise_K2000_gfa_to_fasta.py;
cp src/Bwise_conda $PREFIX/bin/bwise;
