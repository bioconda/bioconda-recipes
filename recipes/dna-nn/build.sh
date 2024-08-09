#!/bin/bash

set -x -e

export CPATH=${PREFIX}/include

mkdir -p "${PREFIX}/bin"

make

chmod +x dna-brnn
chmod +x dna-cnn
chmod +x gen-fq
chmod +x parse-rm.js

cp dna-brnn "${PREFIX}/bin"
cp dna-cnn "${PREFIX}/bin"
cp gen-fq "${PREFIX}/bin"
cp parse-rm.js "${PREFIX}/bin"

