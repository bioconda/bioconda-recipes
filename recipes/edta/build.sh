#!/bin/sh
set -x -e

EDTA_DIR=${PREFIX}/share/EDTA
EDTA_PROGRAMS="EDTA.pl EDTA_raw.pl EDTA_processI.pl"

cp -r * ${EDTA_DIR}

for name in ${EDTA_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/$name ${PREFIX}/share/$name
done
