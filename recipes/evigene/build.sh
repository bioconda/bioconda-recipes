#!/bin/bash

readonly EVIGENEHOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p ${EVIGENEHOME}

cd ${SRC_DIR}

cp -Rp config lib scripts ${EVIGENEHOME}


mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVIGENEHOME=${EVIGENEHOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset EVIGENEHOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh

find $EVIGENEHOME -name *.pl | xargs -I {} sed -i.bak '1 s|#!/usr/bin/perl|#!/usr/bin/env perl|g' {}
find $EVIGENEHOME -name *.perl | xargs -I {} sed -i.bak '1 s|#!/usr/bin/perl|#!/usr/bin/env perl|g' {}
