#!/bin/sh

set -e -u -x

HMMER2_PROGRAMS="hmmalign hmmbuild hmmcalibrate hmmconvert hmmemit hmmfetch hmmindex hmmpfam hmmsearch"

./configure --enable-threads --enable-debugging=3 --prefix=${PREFIX}
make
make install

# debug purpose
ls -l
ls -l src/

#copy tools into the bin and append 2 to not mix with hmmer3
mkdir -p $PREFIX/bin
for name in ${HMMER2_PROGRAMS} ; do
  cp src/${name} ${PREFIX}/bin/${name}2
done

chmod a+x ${PREFIX}/bin/*
