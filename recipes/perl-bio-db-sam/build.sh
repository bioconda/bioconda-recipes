#!/bin/bash

# WARNING this recipe is blacklisted, it is replaced by perl-bio-samtools

wget -O samtools-0.1.20.tar.gz https://github.com/samtools/samtools/archive/0.1.20.tar.gz
tar -xzvpf samtools-0.1.20.tar.gz
cd samtools-0.1.20
make CFLAGS='-g -Wall -O2 -fPIC'
cd ..
export SAMTOOLS=samtools-0.1.20
cpanm -i --build-args='--config lddlflags=-shared' .
