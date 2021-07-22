#!/bin/bash
install -d "${PREFIX}/bin"
install probeit.py "${PREFIX}/bin/"
install -d "${PREFIX}/share/"
cp sample/{positive,negative,ref,str}.fasta sample/ref.gff "${PREFIX}/share/"
#install sample/positive.fasta "${PREFIX}/sample"
#install sample/negative.fasta "${PREFIX}/sample"
#install sample/ref.fasta "${PREFIX}/sample"
#install sample/ref.gff "${PREFIX}/sample"
#install sample/str.fasta "${PREFIX}/sample"
cd setcover
make CXXFLAGS="${CXXFLAGS} -I. -O3 -std=c++14" -j $CPU_COUNT
install setcover "${PREFIX}/bin/"
