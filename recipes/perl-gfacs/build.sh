#!/bin/sh

set -o errexit -o nounset

readonly GFACS_HOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p ${GFACS_HOME}
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d


chmod +x gFACs.pl
cp -Rp format_scripts support_scripts task_scripts gFACs.pl ${GFACS_HOME}

ln -s ${GFACS_HOME}/gFACs.pl ${PREFIX}/bin/gFACs.pl


#helpful ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export GFACS_HOME=${GFACS_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset GFACS_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
