#! /usr/bin/env bash

mkdir -p ${PREFIX}/bin

# compilation
g++ src/harpy/bin/extractReads.cpp -O3 -o ${PREFIX}/bin/extractReads

# install harpy proper
${PYTHON} -m pip install . --no-deps -vvv

# associated scripts
chmod +x src/harpy/bin/* 
cp src/harpy/bin/* ${PREFIX}/bin/