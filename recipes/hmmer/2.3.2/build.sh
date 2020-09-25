#!/bin/sh

set -e -u -x

HMMER2_PROGRAMS="hmmalign hmmbuild hmmcalibrate hmmconvert hmmemit hmmfetch hmmindex hmmpfam hmmsearch"

mkdir -p $PREFIX/bin

./configure --enable-threads --enable-debugging=3
make
make install

ls -l

ls -l src/

for name in ${HMMER2_PROGRAMS} ; do
  cp src/${name} ${PREFIX}/bin/
done

chmod a+x ${PREFIX}/bin/*
