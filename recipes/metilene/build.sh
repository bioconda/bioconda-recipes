#!/bin/sh
make -j ${CPU_COUNT}

cp metilene ${PREFIX}/bin
cp metilene_input.pl ${PREFIX}/bin
cp metilene_output.pl ${PREFIX}/bin
cp metilene_output.R ${PREFIX}/bin

install -d ${PREFIX}/share/doc/metilene
install manual.pdf ${PREFIX}/share/doc/metilene
install README ${PREFIX}/share/doc/metilene
