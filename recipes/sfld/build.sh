#!/bin/sh
set -x -e

PROGRAMS="sfld_preprocess sfld_postprocess sfld_preprocess.py"

# get easel lib from version 3.1b2 of hmmer
curl -sL http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2.tar.gz | tar -xz

# Replace path in EASEL_DIR in Makefile with the 'easel' subdir of the hmmer distribution
sed -i.bak 's|EASEL_DIR=|EASEL_DIR=${PREFIX}/hmmer-3.1b/easel|g' Makefile

#compile
make CC=${CC}

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done
