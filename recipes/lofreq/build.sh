#!/bin/bash
set -eu -o pipefail

CFLAGS="${CFLAGS} -Og -g -pedantic"

pushd src/lofreq/
rm vcf.c
wget https://raw.githubusercontent.com/CSB5/lofreq/master/src/lofreq/vcf.c
popd

./configure --with-htslib=${PREFIX}/lib  --prefix=${PREFIX}

make
make install
