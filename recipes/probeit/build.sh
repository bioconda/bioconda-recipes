#!/bin/bash
install -d "${PREFIX}/bin"
install probeit.py "${PREFIX}/bin/"
install -d "${PREFIX}/bin/sample"
install sample/positive.fasta "${PREFIX}/bin/"
install sample/negative.fasta "${PREFIX}/bin/"
install sample/ref.fasta "${PREFIX}/bin/"
install sample/ref.gff "${PREFIX}/bin/"
install sample/str.fasta "${PREFIX}/bin/"
cd setcover
make CXXFLAGS="${CXXFLAGS} -I. -O3 -std=c++14" -j $CPU_COUNT
install setcover "${PREFIX}/bin/"
