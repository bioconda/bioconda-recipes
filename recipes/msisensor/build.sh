#!/bin/bash
wget https://github.com/samtools/samtools/archive/0.1.19.tar.gz
tar -xzf 0.1.19.tar.gz
cd samtools-0.1.19
make
export SAMTOOLS_ROOT=$PWD
cd ..
make
make install
