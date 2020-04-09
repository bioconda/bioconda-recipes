#!/bin/sh
set -x -e

#list programs
COILS_PROGRAMS="coils-svr.pl coils-wrap.pl"
# remove the precompilated one
rm ncoils-linux
#compile
${CC} -O2 -I. -o ncoils-osf ncoils.c read_matrix.c -lm

# get the name of the ncoils program build
NCOILS=$(ls ncoils-*)

# info for debugging
ls -l

# copy tools in the bin
mkdir -p ${PREFIX}/bin

# Add main tools
cp ${NCOILS} ${PREFIX}/bin/ncoils

# Add extra programs
for PROGRAM in ${COILS_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
done
