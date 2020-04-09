#!/bin/sh
set -x -e

#compile
COILS_PROGRAMS="ncoils  coils-svr.pl coils-wrap.pl"
${CC} -O2 -I. -o ncoils-osf ncoils.c read_matrix.c -lm

ls -l

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${COILS_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
done
