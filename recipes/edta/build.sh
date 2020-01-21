#!/bin/sh
set -x -e

EDTA_DIR=${PREFIX}/share/EDTA
EDTA_PROGRAMS="EDTA.pl EDTA_raw.pl EDTA_processI.pl"

mkdir -p ${PREFIX}/bin
mkdir -p ${EDTA_DIR}
cp -r * ${EDTA_DIR}

for name in ${EDTA_PROGRAMS} ; do
  ln -s ${EDTA_DIR}/$name ${PREFIX}/bin/$name
done
