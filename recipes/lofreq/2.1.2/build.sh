#!/bin/bash
set -eu

wget -O samtools-1.2.tar.gz https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2
tar -xjvpf samtools-1.2.tar.gz
cd samtools-1.2
make
cd ..
./configure --prefix $PREFIX SAMTOOLS=$SRC_DIR/samtools-1.2 HTSLIB=$SRC_DIR/samtools-1.2/htslib-1.2.1
make
make install
