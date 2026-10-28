#!/bin/sh
set -x -e

PROGRAMS="sfld_preprocess sfld_postprocess sfld_preprocess.py"

#info=$( ld -v 2>&1 > /dev/null )
#platform=$([[ $info =~ ld64-([0-9]*) ]] && echo ${BASH_REMATCH[1]})

unset LDFLAGS
unset CFLAGS


# Replace path in EASEL_DIR in Makefile with the 'easel' subdir of the hmmer distribution
sed -i.bak 's|EASEL_DIR=|EASEL_DIR=${CONDA_PREFIX}/share/easel|g' Makefile

#compile
CC=$CC make

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done
