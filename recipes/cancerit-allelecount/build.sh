#!/bin/bash
set -eu

wget -O htslib-1.3.tar.bz2 https://github.com/samtools/htslib/releases/download/1.3/htslib-1.3.tar.bz2
tar -xjvpf htslib-1.3.tar.bz2
cd htslib-1.3
make
cd ../c
mkdir bin
make OPTINC=-I$SRC_DIR/htslib-1.3 HTSLOC=$SRC_DIR/htslib-1.3
mkdir -p $PREFIX/bin
cp bin/alleleCounter $PREFIX/bin
