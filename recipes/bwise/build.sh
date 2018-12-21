#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd src;
g++ -o n50.o -c N50.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o n50 n50.o -flto -fopenmp -lz
g++ -o sequencesToNumbers.o -c sequencesToNumbers.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o sequencesToNumbers sequencesToNumbers.o -flto -fopenmp -lz
g++ -o numbersToSequences.o -c numbersToSequences.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o numbersToSequences numbersToSequences.o -flto -fopenmp -lz
g++ -o numbersFilter.o -c numbersFilter.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o numbersFilter numbersFilter.o -flto -fopenmp -lz
g++ -o simulator.o -c simulator.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o simulator simulator.o -flto -fopenmp -lz
g++ -o path_counter.o -c path_counter.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o path_counter path_counter.o -flto -fopenmp -lz
g++ -o maximal_sr.o -c Maximal_SR.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o maximal_sr maximal_sr.o -flto -fopenmp -lz
g++ -o crush_bulle.o -c crush_bulle.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o crush_bulle crush_bulle.o -flto -fopenmp -lz
g++ -o path_to_kmer.o -c path_to_kmer.cpp -Wall  -Ofast -std=c++11  -flto -pipe -funit-at-a-time  -Wfatal-errors -fopenmp -lz
g++ -o path_to_kmer path_to_kmer.o -flto -fopenmp -lz



mkdir -p $PREFIX/bin;
cp src/path_counter Bwise_path_counter;
cp src/path_to_kmer Bwise_path_to_kmer;
cp src/maximal_sr Bwise_maximal_sr;
cp src/K2000/K2000.py Bwise_K2000.py;
cp src/K2000/K2000_msr_to_gfa.py Bwise_K2000_msr_to_gfa.py;
cp src/K2000/K2000_gfa_to_fasta.py Bwise_K2000_gfa_to_fasta.py;
cp src/Bwise_conda $PREFIX/bin/bwise;
