#!/bin/bash
set -eu

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -wn .
fi

# wget -O samtools-1.3.1.tar.bz2 https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
# tar -xjvpf samtools-1.3.1.tar.bz2
# cd samtools-1.3.1
# make
# cd ..
# ./configure --prefix $PREFIX SAMTOOLS=$SRC_DIR/samtools-1.3.1 HTSLIB=$SRC_DIR/samtools-1.3.1/htslib-1.3.1
# make
# make install

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
