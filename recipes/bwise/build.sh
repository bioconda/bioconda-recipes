#!/bin/bash

cd src
make CC=${CXX} CFLAGS="$CXXFLAGS -fopenmp -L${PREFIX}/lib -lz" LDFLAGS="-L${PREFIX}/lib -flto -fopenmp -lz"

mkdir -p $PREFIX/bin
cp path_counter Bwise_path_counter
cp path_to_kmer Bwise_path_to_kmer
cp maximal_sr Bwise_maximal_sr
cp K2000/K2000.py Bwise_K2000.py
cp K2000/K2000_msr_to_gfa.py Bwise_K2000_msr_to_gfa.py
cp K2000/K2000_gfa_to_fasta.py Bwise_K2000_gfa_to_fasta.py
cp Bwise_conda $PREFIX/bin/bwise
