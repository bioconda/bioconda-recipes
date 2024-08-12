#!/bin/bash

set -x -e

export CPATH=${PREFIX}/include

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT}"

chmod 0755 dna-brnn
chmod 0755 dna-cnn
chmod 0755 gen-fq
chmod 0755 parse-rm.js

cp -rf dna-brnn "${PREFIX}/bin"
cp -rf dna-cnn "${PREFIX}/bin"
cp -rf gen-fq "${PREFIX}/bin"
cp -rf parse-rm.js "${PREFIX}/bin"
