#!/bin/sh
set -x -e

#compile
PFTOOLS_PROGRAMS="ncoils  coils-svr.pl coils-wrap.pl"
${CC} -O2 -I. -o ncoils-osf ncoils.c read_matrix.c -lm

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
done
