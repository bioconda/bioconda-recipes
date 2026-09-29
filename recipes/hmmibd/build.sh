#!/bin/sh

${CC} -o hmmIBD -O3 -Wall ${CFLAGS} hmmIBD.c -lm

install -d "${PREFIX}/bin"
install hmmIBD "${PREFIX}/bin/"

install -m 755 thin_sites.py "${PREFIX}/bin/thin_sites.py"
install -m 755 vcf2hmm.py "${PREFIX}/bin/vcf2hmm.py"
