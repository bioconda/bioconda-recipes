#!/bin/bash

# copy scripts and its dependencies to $PREFIX/bin folder
mkdir -p ${PREFIX}/bin
cp -ar lib \
    utils \
    WGA \
    vcf2alignment \
    vcf2synteny \
    cpanfile \
    Makefile \
    version.txt \
    README.md \
    LICENSE \
    ${PREFIX}/bin

# Red
cd lib && git clone https://github.com/EnsemblGenomes/Red.git && cd Red/src_2.0 && \
    perl -pi.bak -e 's/CXX = g\+\+//' Makefile && \
    make bin && make && cd .. && rm -f bin/*.o && rm -f bin/*/*.o && cd ../..

## Red2Ensembl
cd utils && wget https://raw.githubusercontent.com/Ensembl/plant-scripts/refs/heads/master/repeats/Red2Ensembl.py && \
    chmod +x Red2Ensembl.py && cd ..

# CGaln
cd lib && git clone https://github.com/rnakato/Cgaln.git && cd Cgaln && \
    perl -pi.bak -e 's/CC = gcc//;s/gcc/\$(CC)/' Makefile && make && rm -f *.fasta *.o && cd ../..

# GSAlign
cd lib && git clone https://github.com/hsinnan75/GSAlign.git && cd GSAlign && rm -rf test && \
    perl -pi.bak -e 's/CXX\s+=\s+g\+\+//;' src/makefile && \
    perl -pi.bak -e 's/CC=\s+gcc//;' src/BWT_Index/makefile && make
