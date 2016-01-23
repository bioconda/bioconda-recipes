#!/bin/bash
set -eu


# samtools dependency
wget -O samtools-0.1.19.tar.bz2 https://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2
tar -xjvpf samtools-0.1.19.tar.bz2
cd samtools-0.1.19
make
cd ..

echo 'SAMTOOLS=samtools-0.1.19' > Makefile.local
./INSTALL samtools-0.1.19
mkdir -p $PREFIX/bin
cp pindel pindel2vcf sam2pindel $PREFIX/bin
