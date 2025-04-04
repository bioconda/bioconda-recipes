#!/bin/bash

make \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}"

mkdir -p ${PREFIX}/bin

cp bin/SpliceAwareAligner ${PREFIX}/bin
cp asgal ${PREFIX}/bin
for f in $(ls scripts) ; do cp "scripts/$f" ${PREFIX}"/bin/asgal_$f" ; done
