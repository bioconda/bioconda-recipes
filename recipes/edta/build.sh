#!/bin/sh
set -x -e

EDTA_DIR=${PREFIX}/share/EDTA
EDTA_PROGRAMS="EDTA.pl EDTA_raw.pl EDTA_processI.pl"

for name in ${EDTA_PROGRAMS} ; do
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' -e 's/^#!.*perl.*$/#!\/usr\/bin\/env perl/g'  ${EDTA_PROGRAMS}
  else
    sed -i -e 's/^#!.*perl.*$/#!\/usr\/bin\/env perl/g' ${EDTA_PROGRAMS}
  fi
done

mkdir -p ${PREFIX}/bin
mkdir -p ${EDTA_DIR}
cp -r * ${EDTA_DIR}

for name in ${EDTA_PROGRAMS} ; do
  ln -s ${EDTA_DIR}/$name ${PREFIX}/bin/$name
done
