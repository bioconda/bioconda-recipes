#!/bin/sh
set -x -e

PROGRAMS="sfld_preprocess sfld_postprocess sfld_preprocess.py"

# Replace path in EASEL_DIR in Makefile with the 'easel' subdir of the hmmer distribution
# Hack J. Dainat - fix path to access the tools through the wrapper in the bin otherwise fails
if [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i'' "s|EASEL_DIR=|EASEL_DIR=${PREFIX}/share/easel|g" Makefile
else
	sed -i "s|EASEL_DIR=|EASEL_DIR=${PREFIX}/share/easel|g" Makefile
fi


# for debug
cat Makefile

#compile
make CC=${CC}

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done
