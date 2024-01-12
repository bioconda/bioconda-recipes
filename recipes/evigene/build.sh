#!/bin/bash

readonly EVIGENEHOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p ${EVIGENEHOME}

cd ${SRC_DIR}

cp -Rp config lib scripts ${EVIGENEHOME}


mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVIGENEHOME=${EVIGENEHOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset EVIGENEHOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${EVIGENEHOME}/scripts/prot/tr2aacds.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${EVIGENEHOME}/scripts/prot/tr2aacds4.pl
